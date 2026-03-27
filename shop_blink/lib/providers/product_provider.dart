import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shop_blink/api/shopp_api.dart';

import 'package:shop_blink/models/product.dart';
import 'package:shop_blink/models/response/products_response.dart';
import 'package:shop_blink/providers/cart_provider.dart';
import 'package:shop_blink/services/local_storage.dart';

class ProductProvider extends ChangeNotifier {
  final CartProvider cartProvider;
  ProductProvider(this.cartProvider);

  bool isLoading = false;
  List<Product> products = [];
  String? tamanho;
  int? cor;
  int tamIndex = 0;

  void getProducts() async {
    isLoading = true;
    ShoppAPI.configureDio(
      socket: true,
      token: LocalStorage.prefs.getString('token_socket') ?? '',
    );
    final Map<String, Object> data = {
      'query':
          "select first 20 p.id, "
          "  coalesce(p.nome,'') as title, "
          "  '' as image, p.data_inc, "
          "  cast(coalesce(p.preco_venda1,0) as decimal(12,2)) as price, "
          " coalesce(t.tit01,'') as tam01, "
          " coalesce(t.tit02,'') as tam02, "
          " coalesce(t.tit03,'') as tam03, "
          " coalesce(t.tit04,'') as tam04, "
          " coalesce(t.tit05,'') as tam05, "
          " coalesce(t.tit06,'') as tam06, "
          " coalesce(t.tit07,'') as tam07, "
          " coalesce(t.tit08,'') as tam08, "
          " coalesce(t.tit09,'') as tam09, "
          " coalesce(t.tit10,'') as tam10, "
          " coalesce(t.tit11,'') as tam11, "
          " coalesce(t.tit12,'') as tam12, "
          " coalesce(t.tit13,'') as tam13, "
          " coalesce(t.tit14,'') as tam14, "
          " coalesce(t.tit15,'') as tam15, "
          " sum(coalesce(e.quant_01,0)) as e01, "
          " sum(coalesce(e.quant_02,0)) as e02, "
          " sum(coalesce(e.quant_03,0)) as e03, "
          " sum(coalesce(e.quant_04,0)) as e04, "
          " sum(coalesce(e.quant_05,0)) as e05, "
          " sum(coalesce(e.quant_06,0)) as e06, "
          " sum(coalesce(e.quant_07,0)) as e07, "
          " sum(coalesce(e.quant_08,0)) as e08, "
          " sum(coalesce(e.quant_09,0)) as e09, "
          " sum(coalesce(e.quant_10,0)) as e10, "
          " sum(coalesce(e.quant_11,0)) as e11, "
          " sum(coalesce(e.quant_12,0)) as e12, "
          " sum(coalesce(e.quant_13,0)) as e13, "
          " sum(coalesce(e.quant_14,0)) as e14, "
          " sum(coalesce(e.quant_15,0)) as e15 "
          " from produto p  "
          " left join tamanhos t on t.id = p.id_tama  "
          " left join estoque e on e.id_loja = (select first 1 loja_padrao from parametro) and e.id_produto = p.id "
          "  where p.status <> 'C' and coalesce(e.status,'N') <> 'C' and coalesce(p.preco_venda1,0) > 1.00 "
          // "  and e.quant_tot > 0"
          "  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 order by p.data_inc desc",
    };
    try {
      final resp = await ShoppAPI.post('/query', data);
      final productsReponse = ProductsReponse.fromJson(resp);
      products.clear();
      products.addAll(productsReponse.data);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void searchProducts(String search) async {
    isLoading = true;
    products.clear();
    notifyListeners();

    final Map<String, Object> data = {
      'query':
          "select first 20 p.id, "
          "  coalesce(p.nome,'') as title, "
          "  '' as image, "
          "  cast(coalesce(p.preco_venda1,0) as decimal(12,2)) as price, "
          " coalesce(t.tit01,'') as tam01, "
          " coalesce(t.tit02,'') as tam02, "
          " coalesce(t.tit03,'') as tam03, "
          " coalesce(t.tit04,'') as tam04, "
          " coalesce(t.tit05,'') as tam05, "
          " coalesce(t.tit06,'') as tam06, "
          " coalesce(t.tit07,'') as tam07, "
          " coalesce(t.tit08,'') as tam08, "
          " coalesce(t.tit09,'') as tam09, "
          " coalesce(t.tit10,'') as tam10, "
          " coalesce(t.tit11,'') as tam11, "
          " coalesce(t.tit12,'') as tam12, "
          " coalesce(t.tit13,'') as tam13, "
          " coalesce(t.tit14,'') as tam14, "
          " coalesce(t.tit15,'') as tam15, "
          " sum(coalesce(e.quant_01,0)) as e01, "
          " sum(coalesce(e.quant_02,0)) as e02, "
          " sum(coalesce(e.quant_03,0)) as e03, "
          " sum(coalesce(e.quant_04,0)) as e04, "
          " sum(coalesce(e.quant_05,0)) as e05, "
          " sum(coalesce(e.quant_06,0)) as e06, "
          " sum(coalesce(e.quant_07,0)) as e07, "
          " sum(coalesce(e.quant_08,0)) as e08, "
          " sum(coalesce(e.quant_09,0)) as e09, "
          " sum(coalesce(e.quant_10,0)) as e10, "
          " sum(coalesce(e.quant_11,0)) as e11, "
          " sum(coalesce(e.quant_12,0)) as e12, "
          " sum(coalesce(e.quant_13,0)) as e13, "
          " sum(coalesce(e.quant_14,0)) as e14, "
          " sum(coalesce(e.quant_15,0)) as e15 "
          " from produto p  "
          " left join tamanhos t on t.id = p.id_tama  "
          " left join estoque e on e.id_loja = (select first 1 loja_padrao from parametro) and e.id_produto = p.id "
          "  where p.status <> 'C' and coalesce(e.status,'N') <> 'C' and coalesce(p.preco_venda1,0) > 1.00 "
          " and ((upper(p.nome) like upper('%$search%')) or (upper(p.id) = upper('$search'))) and coalesce(p.preco_venda1,0) > 0 "
          "  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19",
    };
    final resp = await ShoppAPI.post('/query', data);
    final productsReponse = ProductsReponse.fromJson(resp);
    products.clear();
    products.addAll(productsReponse.data);
    isLoading = false;
    notifyListeners();
  }

  void searchCodBarr(String search) async {
    try {
      isLoading = true;
      products.clear();
      notifyListeners();
      final codBarr = search.substring(0, 6);
      // final tam = search.substring(8, 10); - versão para código de barras com tamanho NORMAL

      // nova leitura para codigo antigo
      final tam = search.substring(9, 10);
      // nãp está sendo usado! não apagar pois pode ser útil para clientes com cor
      // no código de barras
      // final cor = search.substring(7, 8) +
      //     search.substring(6, 7) +
      //     search.substring(10, 12);
      final Map<String, Object> data = {
        'query':
            "select first 20 p.id, "
            "  coalesce(p.nome,'') as title, "
            "  '' as image, "
            "  cast(coalesce(p.preco_venda1,0) as decimal(12,2)) as price, "
            " coalesce(t.tit01,'') as tam01, "
            " coalesce(t.tit02,'') as tam02, "
            " coalesce(t.tit03,'') as tam03, "
            " coalesce(t.tit04,'') as tam04, "
            " coalesce(t.tit05,'') as tam05, "
            " coalesce(t.tit06,'') as tam06, "
            " coalesce(t.tit07,'') as tam07, "
            " coalesce(t.tit08,'') as tam08, "
            " coalesce(t.tit09,'') as tam09, "
            " coalesce(t.tit10,'') as tam10, "
            " coalesce(t.tit11,'') as tam11, "
            " coalesce(t.tit12,'') as tam12, "
            " coalesce(t.tit13,'') as tam13, "
            " coalesce(t.tit14,'') as tam14, "
            " coalesce(t.tit15,'') as tam15, "
            " coalesce(sum(coalesce(e.quant_01,0)),0) as e01, "
            " coalesce(sum(coalesce(e.quant_02,0)),0) as e02, "
            " coalesce(sum(coalesce(e.quant_03,0)),0) as e03, "
            " coalesce(sum(coalesce(e.quant_04,0)),0) as e04, "
            " coalesce(sum(coalesce(e.quant_05,0)),0) as e05, "
            " coalesce(sum(coalesce(e.quant_06,0)),0) as e06, "
            " coalesce(sum(coalesce(e.quant_07,0)),0) as e07, "
            " coalesce(sum(coalesce(e.quant_08,0)),0) as e08, "
            " coalesce(sum(coalesce(e.quant_09,0)),0) as e09, "
            " coalesce(sum(coalesce(e.quant_10,0)),0) as e10, "
            " coalesce(sum(coalesce(e.quant_11,0)),0) as e11, "
            " coalesce(sum(coalesce(e.quant_12,0)),0) as e12, "
            " coalesce(sum(coalesce(e.quant_13,0)),0) as e13, "
            " coalesce(sum(coalesce(e.quant_14,0)),0) as e14, "
            " coalesce(sum(coalesce(e.quant_15,0)),0) as e15 "
            " from produto p  "
            " left join tamanhos t on t.id = p.id_tama  "
            " left join estoque e on e.id_loja = (select first 1 loja_padrao from parametro) and e.id_produto = p.id "
            "  where p.status <> 'C' and coalesce(e.status,'N') <> 'C' and coalesce(p.preco_venda1,0) > 1.00 "
            " and p.codredu = $codBarr and coalesce(p.preco_venda1,0) > 0 "
            "  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19",
      };
      // print('====== CODIGO DE BARRAS ======');
      // print(codBarr);
      final resp = await ShoppAPI.post('/query', data);
      final productsReponse = ProductsReponse.fromJson(resp);
      if (productsReponse.data.isEmpty) {
        isLoading = false;
        notifyListeners();
        return;
      }

      products.clear();
      products.addAll(productsReponse.data);

      tamIndex = 0;
      if (tam == '0') {
        tamanho = products.first.tam01 ?? '';
        tamIndex = 0;
      }
      if (tam == '1') {
        tamanho = products.first.tam02 ?? '';
        tamIndex = 1;
      }
      if (tam == '2') {
        tamanho = products.first.tam03 ?? '';
        tamIndex = 2;
      }
      if (tam == '3') {
        tamanho = products.first.tam04 ?? '';
        tamIndex = 3;
      }
      if (tam == '4') {
        tamanho = products.first.tam05 ?? '';
        tamIndex = 4;
      }
      if (tam == '5') {
        tamanho = products.first.tam06 ?? '';
        tamIndex = 5;
      }
      if (tam == '6') {
        tamanho = products.first.tam07 ?? '';
        tamIndex = 6;
      }
      if (tam == '7') {
        tamanho = products.first.tam08 ?? '';
        tamIndex = 7;
      }
      if (tam == '8') {
        tamanho = products.first.tam09 ?? '';
        tamIndex = 8;
      }
      if (tam == '9') {
        tamanho = products.first.tam10 ?? '';
        tamIndex = 9;
      }
      // if (tam == '10') {
      //   tamanho = products.first.tam11 ?? '';
      //   tamIndex = 10;
      // }
      // if (tam == '11') {
      //   tamanho = products.first.tam12 ?? '';
      //   tamIndex = 11;
      // }
      // if (tam == '12') {
      //   tamanho = products.first.tam13 ?? '';
      //   tamIndex = 12;
      // }
      // if (tam == '13') {
      //   tamanho = products.first.tam14 ?? '';
      //   tamIndex = 13;
      // }
      // if (tam == '14') {
      //   tamanho = products.first.tam15 ?? '';
      //   tamIndex = 14;
      // }
      // cartProvider.addItemCart(products.first, 1, tamanho ?? '');
      isLoading = false;
      notifyListeners();
    } on Exception {
      rethrow;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal(BuildContext context) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (context.mounted) {
      if (barcodeScanRes != '-1') {
        searchCodBarr(barcodeScanRes);
      }
    }
  }
}
