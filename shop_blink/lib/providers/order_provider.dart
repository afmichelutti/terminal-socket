import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shop_blink/api/shopp_api.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/models/cart.dart';
import 'package:shop_blink/models/order.dart';
import 'package:shop_blink/models/order_item.dart';
import 'package:shop_blink/models/response/order_items_response.dart';
import 'package:shop_blink/models/response/order_response.dart';
import 'package:shop_blink/models/response/orders_response.dart';
import 'package:shop_blink/models/response/total_response.dart';
import 'package:shop_blink/models/salesman.dart';
import 'package:shop_blink/providers/cart_provider.dart';
import 'package:uuid/uuid.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> orders = [];
  bool isSaving = false;
  bool isLoading = false;
  var uuid = const Uuid();
  int totalPecas = 0;
  double total = 0.0;
  List<OrderItem> orderItems = [];

  int quantitySalesman = 0;
  double amountSalesman = 0.0;

  Future<void> saveOrder(
    BuildContext context,
    List<Cart> listCart,
    int totalPecas,
    double total,
    Salesman salesman,
    CartProvider cartProvider,
  ) async {
    isSaving = true;
    notifyListeners();
    final Map<String, Object> data = {
      'query':
          "insert into orcamento (id,status,marca,data,id_loja,id_vend,id_cliente,id_orcamento_status,total_liquido,total_bruto,desconto,id_cod) "
          "values (gen_id(gen_orcamento,1),'N','S',current_date,(select first 1 loja_padrao from parametro),${salesman.id},(select first 1 id_cliente from parametro),"
          "(select first 1 id from orcamento_status where status <> 'C'),$total,$total,0,gen_id(gen_orcamento_id_cod,1)) returning id, id_cod",
    };
    final resp = await ShoppAPI.post('/query', data);

    try {
      var jsonObj = json.decode(resp);
      var prettyJson = JsonEncoder.withIndent('  ').convert(jsonObj);
      debugPrint('Resposta da API formatada:\n$prettyJson');
    } catch (e) {
      debugPrint('Erro ao formatar JSON: $e');
      debugPrint('Resposta da API (bruta): $resp');
    }

    final orderResponse = OrderResponse.fromJson(resp);
    final orderId = orderResponse.data[0].id;
    // final codigo = orderResponse.data[0].idCod;
    debugPrint(orderId.toString());
    listCart.asMap().forEach((key, cart) async {
      final Map<String, Object> data = {
        'query':
            "insert into orcamento_item (id,status,marca,id_orcamento,id_produto,id_tama,id_cor,quantidade,preco_unitario,nro_item,preco_tabela,preco_custo,desc_item,preco_sem_desconto) "
            " values (gen_id(gen_orcamento_item,1),'N','N',$orderId,'${cart.product.id}','${cart.tamanho}',(select first 1 coalesce(parametro.cor_padrao,(select first 1 id from cores)) "
            " as id from parametro),${cart.quantidade},${cart.product.price},${key + 1}, "
            " ${cart.product.price},0,0,${cart.product.price}) returning id",
      };
      debugPrint(data.toString());
      await ShoppAPI.post('/query', data);
    });
    isSaving = false;
    cartProvider.clearCartList();
    if (context.mounted) {
      toasty(
        context,
        'Orçamento incluido com sucesso!',
        gravity: ToastGravity.BOTTOM_RIGHT,
        bgColor: kPrimaryColor,
        textColor: Colors.white,
      );
    }

    notifyListeners();
  }

  void getAmount(Salesman salesman) async {
    isLoading = true;
    // notifyListeners();
    final Map<String, Object> data = {
      'query':
          "select sum(coalesce(orcamento.total_liquido,0)) as amount, sum(coalesce((select sum(orcamento_item.quantidade) "
          "from orcamento_item where status <> 'C' and orcamento_item.id_orcamento = orcamento.id ),0)) as quantidade from orcamento "
          "left join vendint on vendint.id = orcamento.id_vend where orcamento.status <> 'C' and orcamento.id_vend = ${salesman.id} "
          "and orcamento.id_loja = (select first 1 loja_padrao from parametro) and orcamento.data = current_date and orcamento.id_vendas is null ",
    };
    final resp = await ShoppAPI.post('/query', data);
    final totalResponse = TotalResponse.fromJson(resp);
    amountSalesman = totalResponse.data[0].amount;
    quantitySalesman = totalResponse.data[0].quantidade;
    isLoading = false;
    notifyListeners();
  }

  void getOrders(Salesman salesman) async {
    isLoading = true;
    // notifyListeners();
    final Map<String, Object> data = {
      'query':
          "select orcamento.id,orcamento.id_cod as codigo,orcamento.data_com,vendint.nome as salesman,"
          "coalesce(orcamento.total_liquido,0) as amount, coalesce((select sum(orcamento_item.quantidade) "
          "from orcamento_item where status <> 'C' and orcamento_item.id_orcamento = orcamento.id ),0) as quantidade from orcamento "
          "left join vendint on vendint.id = orcamento.id_vend where orcamento.status <> 'C' and orcamento.id_vend = ${salesman.id} "
          "and orcamento.id_loja = (select first 1 loja_padrao from parametro) and orcamento.data = current_date and orcamento.id_vendas is null order by orcamento.id_cod desc",
      // "and orcamento.id_loja = (select first 1 loja_padrao from parametro) and orcamento.data = current_date order by orcamento.id_cod desc"
    };
    final resp = await ShoppAPI.post('/query', data);
    final ordersResponse = OrdersResponse.fromJson(resp);
    orders.clear();
    orders.addAll(ordersResponse.data);
    isLoading = false;
    notifyListeners();
  }

  void getOrderItems(int orderId) async {
    isLoading = true;
    // notifyListeners();
    final Map<String, Object> data = {
      'query':
          "select oi.id_orcamento as orderId, oi.nro_item as nroItem, p.nome as nomeProduto, oi.id_tama as tamanho, oi.quantidade, oi.preco_unitario as price "
          " from orcamento_item oi left join produto p on p.id = oi.id_produto "
          " where oi.status <> 'C' and oi.id_orcamento = $orderId order by oi.nro_item",
    };
    final resp = await ShoppAPI.post('/query', data);
    final orderItemsResponse = OrderItemsResponse.fromJson(resp);
    orderItems.clear();
    orderItems.addAll(orderItemsResponse.data);
    isLoading = false;
    notifyListeners();
  }

  Future<Order?> getOrder(int orderId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Primeiro, buscar o pedido
      final Map<String, Object> orderData = {
        'query': """
        select 
          orcamento.id,
          orcamento.id_cod as codigo,
          orcamento.data_com,
          vendint.nome as salesman,
          coalesce(orcamento.total_liquido,0) as amount,
          coalesce((
            select sum(orcamento_item.quantidade)
            from orcamento_item 
            where status <> 'C' and orcamento_item.id_orcamento = orcamento.id
          ),0) as quantidade
        from orcamento
        left join vendint on vendint.id = orcamento.id_vend
        where orcamento.status <> 'C'
        and orcamento.id = $orderId
      """,
      };

      final orderResp = await ShoppAPI.post('/query', orderData);
      final orderResponse = OrdersResponse.fromJson(orderResp);

      if (orderResponse.data.isEmpty) {
        isLoading = false;
        notifyListeners();
        return null;
      }

      // Depois, buscar os itens do pedido
      final Map<String, Object> itemsData = {
        'query': """
        select 
          oi.id_orcamento as orderid,
          oi.nro_item as nroitem,
          p.nome as nomeproduto,
          oi.id_tama as tamanho,
          oi.quantidade,
          oi.preco_unitario as price
        from orcamento_item oi
        left join produto p on p.id = oi.id_produto
        where oi.status <> 'C'
        and oi.id_orcamento = $orderId
        order by oi.nro_item
      """,
      };

      final itemsResp = await ShoppAPI.post('/query', itemsData);
      final itemsResponse = OrderItemsResponse.fromJson(itemsResp);

      // Criar o Order completo com os items
      final order = Order(
        id: orderResponse.data[0].id,
        codigo: orderResponse.data[0].codigo,
        dataCom: orderResponse.data[0].dataCom,
        salesman: orderResponse.data[0].salesman,
        amount: orderResponse.data[0].amount,
        quantidade: orderResponse.data[0].quantidade,
        items: itemsResponse.data,
      );

      isLoading = false;
      notifyListeners();

      return order;
    } catch (e) {
      debugPrint('Erro ao buscar pedido: $e');
      isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
