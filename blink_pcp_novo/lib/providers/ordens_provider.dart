import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painel_producao_blink/api/cafe_api.dart';
import 'package:painel_producao_blink/models/cartoes.dart';
import 'package:painel_producao_blink/models/ordem.dart';
import 'package:painel_producao_blink/models/ordens_response.dart';
import 'package:painel_producao_blink/models/producao_response.dart';

class OrdensProvider extends ChangeNotifier {
  List<Ordem> ordensProducao = [];
  List<Ordem> ordensCorte = [];
  List<Ordem> ordensServico = [];

  List<Ordem> fordensProducao = [];
  List<Ordem> fordensCorte = [];
  List<Ordem> fordensServico = [];

  bool searching = false;

  int totalPecasSearchProducao = 0;
  int totalPecasSearchServico = 0;
  int totalPecasSearchCorte = 0;

  int opAtraso = 0;
  int opHoje = 0;
  int opVencer = 0;

  int ocAtraso = 0;
  int ocHoje = 0;
  int ocVencer = 0;

  int ocAtrasoQtd = 0;
  int ocHojeQtd = 0;
  int ocVencerQtd = 0;

  int osAtraso = 0;
  int osHoje = 0;
  int osVencer = 0;

  int osAtrasoQtd = 0;
  int osHojeQtd = 0;
  int osVencerQtd = 0;

  double opAtrasoValor = 0;
  double opHojeValor = 0;
  double opVencerValor = 0;

  int opAtrasoQtd = 0;
  int opHojeQtd = 0;
  int opVencerQtd = 0;

  double ocAtrasoValor = 0;
  double ocHojeValor = 0;
  double ocVencerValor = 0;

  double osAtrasoValor = 0;
  double osHojeValor = 0;
  double osVencerValor = 0;

  int qtdProducaoMesAtual = 0;
  int qtdProducaoMesAnterior = 0;
  int qtdServicoMesAnterior = 0;

  List<CartaoModel> cards = [];

  int totalReg = 0;
  bool isLoading = true;

  bool ascending = true;
  int? sortColumnIndex;

  findObservacao() {
    fordensProducao.clear();
    fordensCorte.clear();
    searching = false;
    for (Ordem ordem in ordensProducao) {
      if (ordem.observacao.isNotEmpty) {
        fordensProducao.add(ordem);
        searching = true;
      }
    }
    fordensCorte.clear();
    for (Ordem ordem in ordensCorte) {
      if (ordem.observacao.isNotEmpty) {
        fordensCorte.add(ordem);
        searching = true;
      }
    }
    fordensServico.clear();
    for (Ordem ordem in ordensServico) {
      if (ordem.observacao.isNotEmpty) {
        fordensServico.add(ordem);
        searching = true;
      }
    }
    notifyListeners();
  }

  findPedidos() {
    fordensProducao.clear();
    fordensCorte.clear();
    fordensServico.clear();
    searching = false;
    for (Ordem ordem in ordensProducao) {
      if (ordem.pedido > 0) {
        fordensProducao.add(ordem);
        searching = true;
      }
    }
    fordensCorte.clear();
    for (Ordem ordem in ordensCorte) {
      if (ordem.pedido > 0) {
        fordensCorte.add(ordem);
        searching = true;
      }
    }
    fordensServico.clear();
    for (Ordem ordem in ordensServico) {
      fordensServico.add(ordem);
      searching = true;
    }
    notifyListeners();
  }

  clearSearch() {
    searching = false;
    fordensProducao.clear();
    fordensCorte.clear();
    fordensServico.clear();
    totalPecasSearchProducao = 0;
    totalPecasSearchCorte = 0;
    totalPecasSearchServico = 0;
    notifyListeners();
  }

  findProducao(String value) {
    if (value.isEmpty) {
      searching = false;
      fordensProducao.clear();
      notifyListeners();
      return;
    }

    fordensProducao.clear();
    totalPecasSearchProducao = 0;

    for (Ordem ordem in ordensProducao) {
      // busca por nome
      String nome = ordem.nome.toLowerCase().trim();
      if (nome.contains(value.toLowerCase().trim())) {
        fordensProducao.add(ordem);
        totalPecasSearchProducao = totalPecasSearchProducao + ordem.quantidade;
        searching = true;
      }

      String idProduto = ordem.idProduto.toLowerCase().trim();
      if (idProduto.contains(value.toLowerCase().trim())) {
        fordensProducao.add(ordem);
        totalPecasSearchProducao = totalPecasSearchProducao + ordem.quantidade;
        searching = true;
      }

      String celula = ordem.celula.toLowerCase().trim();
      if (celula.contains(value.toLowerCase().trim())) {
        fordensProducao.add(ordem);
        totalPecasSearchProducao = totalPecasSearchProducao + ordem.quantidade;
        searching = true;
      } else {
        String obs = ordem.observacao.toLowerCase().trim();
        if (obs.contains(value.toLowerCase().trim())) {
          fordensProducao.add(ordem);
          totalPecasSearchProducao =
              totalPecasSearchProducao + ordem.quantidade;
          searching = true;
        }
      }
    }
    notifyListeners();
  }

  findCorte(String value) {
    if (value.isEmpty) {
      fordensCorte.clear();
      notifyListeners();
      return;
    }
    fordensCorte.clear();
    totalPecasSearchCorte = 0;

    for (Ordem ordem in ordensCorte) {
      // busca por nome
      String nome = ordem.nome.toLowerCase().trim();
      if (nome.contains(value.toLowerCase().trim())) {
        fordensCorte.add(ordem);
        totalPecasSearchCorte = totalPecasSearchCorte + ordem.quantidade;
      }

      String idProduto = ordem.idProduto.toLowerCase().trim();
      if (idProduto.contains(value.toLowerCase().trim())) {
        fordensCorte.add(ordem);
        totalPecasSearchCorte = totalPecasSearchCorte + ordem.quantidade;
      }

      String obs = ordem.observacao.toLowerCase().trim();
      if (obs.contains(value.toLowerCase().trim())) {
        fordensCorte.add(ordem);
        totalPecasSearchCorte = totalPecasSearchCorte + ordem.quantidade;
      }

      String celula = ordem.celula.toLowerCase().trim();
      if (celula.contains(value.toLowerCase().trim())) {
        fordensCorte.add(ordem);
        totalPecasSearchCorte = totalPecasSearchCorte + ordem.quantidade;
      }
    }
    notifyListeners();
  }

  findServico(String value) {
    if (value.isEmpty) {
      fordensServico.clear();
      notifyListeners();
      return;
    }
    fordensServico.clear();
    totalPecasSearchServico = 0;
    for (Ordem ordem in ordensServico) {
      // busca por nome
      String nome = ordem.nome.toLowerCase().trim();
      if (nome.contains(value.toLowerCase().trim())) {
        fordensServico.add(ordem);
        totalPecasSearchServico = totalPecasSearchServico + ordem.quantidade;
      }

      String idProduto = ordem.idProduto.toLowerCase().trim();
      if (idProduto.contains(value.toLowerCase().trim())) {
        fordensServico.add(ordem);
        totalPecasSearchServico = totalPecasSearchServico + ordem.quantidade;
      }

      String obs = ordem.observacao.toLowerCase().trim();
      if (obs.contains(value.toLowerCase().trim())) {
        fordensServico.add(ordem);
        totalPecasSearchServico = totalPecasSearchServico + ordem.quantidade;
      }

      String celula = ordem.celula.toLowerCase().trim();
      if (celula.contains(value.toLowerCase().trim())) {
        fordensServico.add(ordem);
        totalPecasSearchServico = totalPecasSearchServico + ordem.quantidade;
      }
    }
    notifyListeners();
  }

  getOrdensCorte(String tipo) async {
    cards.clear();
    isLoading = true;
    final Map<String, Object> data = {
      'query':
          "select pp.id, pp.nro_ordem as ordem, coalesce(pv.nro_pedido,0) as pedido, coalesce(cl.nome,'') as nome_cliente, "
          "coalesce(pp.observacao,'') as observacao, pp.data_inc as data_ordem, pp.prev_entrega, pp.id_produto, p.nome, pp.quantidade, "
          "(pp.prev_entrega - current_date) as dias, pp.celula,case tipo_ordem when 'C' then 'Corte' when 'P' then 'Produção'when 'S' then 'Serviço' end as tipo, "
          "coalesce(p.preco_venda1,0) as preco_venda, pp.data_emissao as emissao "
          " from producao pp "
          "left join produto p on p.id = pp.id_produto "
          "left join pvenda pv on pv.id = pp.pvenda left join clifor cl on cl.id = pv.id_cliente "
          "where pp.data_atualizacao = '12/30/1899' and pp.tipo_ordem = '$tipo'  and pp.data_emissao >= '06/01/2023' order by (pp.prev_entrega - current_date)",
    };
    final resp = await CafeApi.post('/query', data);
    final ordensResp = OrdensResponse.fromMap(
      jsonDecode(resp) as Map<String, dynamic>,
    );

    ordensCorte.clear();
    ordensCorte.addAll(ordensResp.ordens);
    ocAtraso = ordensCorte.where((element) => element.dias < 0).length;
    ocHoje = ordensCorte.where((element) => element.dias == 0).length;
    ocVencer = ordensCorte.where((element) => element.dias > 0).length;

    ocAtrasoValor = 0;
    ocAtrasoQtd = 0;
    for (var ordem in ordensCorte) {
      if (ordem.dias < 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        ocAtrasoValor = ocAtrasoValor + (ordem.quantidade * preco);
        ocAtrasoQtd = ocAtrasoQtd + ordem.quantidade;
      }
    }

    ocHojeValor = 0;
    ocHojeQtd = 0;
    for (var ordem in ordensCorte) {
      if (ordem.dias == 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        ocHojeValor = ocHojeValor + (ordem.quantidade * preco);
        ocHojeQtd = ocHojeQtd + ordem.quantidade;
      }
    }

    ocVencerValor = 0;
    ocVencerQtd = 0;
    for (var ordem in ordensCorte) {
      if (ordem.dias > 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        ocVencerValor = ocVencerValor + (ordem.quantidade * preco);
        ocVencerQtd = ocVencerQtd + ordem.quantidade;
      }
    }

    final real = NumberFormat('R\$ #,##0.00', 'pt_BR');
    cards.add(
      CartaoModel(
        titulo: 'Corte',
        color: Colors.green.shade100,
        subtitulo: 'Atraso',
        valor: ocAtraso.toString(),
        total: real.format(ocAtrasoValor),
        quantidade: ocAtrasoQtd.toString(),
      ),
    );
    cards.add(
      CartaoModel(
        titulo: 'Corte',
        color: Colors.green.shade100,
        subtitulo: 'Hoje',
        valor: ocHoje.toString(),
        total: real.format(ocHojeValor),
        quantidade: ocHojeQtd.toString(),
      ),
    );
    cards.add(
      CartaoModel(
        titulo: 'Corte',
        color: Colors.green.shade100,
        subtitulo: 'Vencer',
        valor: ocVencer.toString(),
        total: real.format(ocVencerValor),
        quantidade: ocVencerQtd.toString(),
      ),
    );
    isLoading = false;
    notifyListeners();
  }

  getOrdensServico(String tipo) async {
    // cards.clear();
    isLoading = true;
    final Map<String, Object> data = {
      'query':
          "select pp.id, pp.nro_ordem as ordem, coalesce(pv.nro_pedido,0) as pedido, coalesce(cl.nome,'') as nome_cliente, "
          "coalesce(pp.observacao,'') as observacao, pp.data_inc as data_ordem, pp.prev_entrega, pp.id_produto, p.nome, pp.quantidade, "
          "(pp.prev_entrega - current_date) as dias, pp.celula,case tipo_ordem when 'C' then 'Corte' when 'P' then 'Produção'when 'S' then 'Serviço' end as tipo, "
          "coalesce(p.preco_venda1,0) as preco_venda, pp.data_emissao as emissao "
          " from producao pp "
          "left join produto p on p.id = pp.id_produto "
          "left join pvenda pv on pv.id = pp.pvenda left join clifor cl on cl.id = pv.id_cliente "
          "where pp.data_atualizacao = '12/30/1899' and pp.tipo_ordem = '$tipo'  and pp.data_emissao >= '06/01/2023' order by (pp.prev_entrega - current_date)",
    };
    final resp = await CafeApi.post('/query', data);
    final ordensResp = OrdensResponse.fromMap(
      jsonDecode(resp) as Map<String, dynamic>,
    );

    ordensServico.clear();
    ordensServico.addAll(ordensResp.ordens);
    osAtraso = ordensServico.where((element) => element.dias < 0).length;
    osHoje = ordensServico.where((element) => element.dias == 0).length;
    osVencer = ordensServico.where((element) => element.dias > 0).length;

    osAtrasoValor = 0;
    osAtrasoQtd = 0;
    for (var ordem in ordensServico) {
      if (ordem.dias < 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        osAtrasoValor = osAtrasoValor + (ordem.quantidade * preco);
        osAtrasoQtd = osAtrasoQtd + ordem.quantidade;
      }
    }

    osHojeValor = 0;
    osHojeQtd = 0;
    for (var ordem in ordensServico) {
      if (ordem.dias == 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        osHojeValor = osHojeValor + (ordem.quantidade * preco);
        osHojeQtd = osHojeQtd + ordem.quantidade;
      }
    }

    osVencerValor = 0;
    osVencerQtd = 0;
    for (var ordem in ordensServico) {
      if (ordem.dias > 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        osVencerValor = osVencerValor + (ordem.quantidade * preco);
        osVencerQtd = osVencerQtd + ordem.quantidade;
      }
    }

    final real = NumberFormat('R\$ #,##0.00', 'pt_BR');
    cards.add(
      CartaoModel(
        titulo: 'Serviço',
        color: Colors.green.shade100,
        subtitulo: 'Atraso',
        valor: osAtraso.toString(),
        total: real.format(osAtrasoValor),
        quantidade: osAtrasoQtd.toString(),
      ),
    );
    cards.add(
      CartaoModel(
        titulo: 'Serviço',
        color: Colors.green.shade100,
        subtitulo: 'Hoje',
        valor: osHoje.toString(),
        total: real.format(osHojeValor),
        quantidade: osHojeQtd.toString(),
      ),
    );
    cards.add(
      CartaoModel(
        titulo: 'Serviço',
        color: Colors.green.shade100,
        subtitulo: 'Vencer',
        valor: osVencer.toString(),
        total: real.format(osVencerValor),
        quantidade: osVencerQtd.toString(),
      ),
    );
    isLoading = false;
    notifyListeners();
  }

  getOrdensProducao(String tipo) async {
    isLoading = true;
    final Map<String, Object> data = {
      'query':
          "select pp.id, pp.nro_ordem as ordem, coalesce(pp.pvenda,0) as pedido, coalesce(cl.nome,'') as nome_cliente, "
          "coalesce(pp.observacao,'') as observacao, pp.data_inc as data_ordem, pp.prev_entrega, pp.id_produto, p.nome, pp.quantidade, "
          "(pp.prev_entrega - current_date) as dias, pp.celula,case tipo_ordem when 'C' then 'Corte' when 'P' then 'Produção'when 'S' then 'Serviço' end as tipo, "
          "coalesce(p.preco_venda1,0) as preco_venda, pp.data_emissao as emissao "
          " from producao pp "
          "left join produto p on p.id = pp.id_produto "
          "left join pvenda pv on pv.id = pp.pvenda left join clifor cl on cl.id = pv.id_cliente "
          "where pp.data_atualizacao = '12/30/1899' and pp.tipo_ordem = '$tipo' and pp.data_emissao >= '06/01/2023' order by (pp.prev_entrega - current_date)",
    };

    final resp = await CafeApi.post('/query', data);
    final ordensResp = OrdensResponse.fromMap(
      jsonDecode(resp) as Map<String, dynamic>,
    );

    ordensProducao.clear();
    ordensProducao.addAll(ordensResp.ordens);
    opAtraso = ordensProducao.where((element) => element.dias < 0).length;
    opHoje = ordensProducao.where((element) => element.dias == 0).length;
    opVencer = ordensProducao.where((element) => element.dias > 0).length;

    opAtrasoValor = 0;
    opAtrasoQtd = 0;
    for (var ordem in ordensProducao) {
      if (ordem.dias < 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        opAtrasoValor = opAtrasoValor + (ordem.quantidade * preco);
        opAtrasoQtd = opAtrasoQtd + ordem.quantidade;
      }
    }

    opHojeValor = 0;
    opHojeQtd = 0;
    for (var ordem in ordensProducao) {
      if (ordem.dias == 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        opHojeValor = opHojeValor + (ordem.quantidade * preco);
        opHojeQtd = opHojeQtd + ordem.quantidade;
      }
    }

    opVencerValor = 0;
    opVencerQtd = 0;
    for (var ordem in ordensProducao) {
      if (ordem.dias > 0) {
        double preco = ordem.precoVenda;
        if (preco <= 0) preco = 100;
        opVencerValor = opVencerValor + (ordem.quantidade * preco);
        opVencerQtd = opVencerQtd + ordem.quantidade;
      }
    }

    final real = NumberFormat('R\$ #,##0.00', 'pt_BR');

    cards.add(
      CartaoModel(
        titulo: 'Produção',
        color: Colors.purple.shade100,
        subtitulo: 'Atraso',
        valor: opAtraso.toString(),
        // total: real.parse(opAtrasoValor.toStringAsFixed(2)).toString(),
        total: real.format(opAtrasoValor),
        quantidade: opAtrasoQtd.toString(),
      ),
    );
    cards.add(
      CartaoModel(
        titulo: 'Produção',
        color: Colors.purple.shade100,
        subtitulo: 'Hoje',
        valor: opHoje.toString(),
        total: real.format(opHojeValor),
        quantidade: opHojeQtd.toString(),
      ),
    );
    cards.add(
      CartaoModel(
        titulo: 'Produção',
        color: Colors.purple.shade100,
        subtitulo: 'Vencer',
        valor: opVencer.toString(),
        total: real.format(opVencerValor),
        quantidade: opVencerQtd.toString(),
      ),
    );

    isLoading = false;
    notifyListeners();
  }

  getProducaoMesAtual() async {
    isLoading = true;
    final Map<String, Object> data = {
      'query':
          "select 'Atual' as mes, coalesce(SUM(quantidade),0) as quantidade from kardex where operacao = 'Entrada PCP' "
          " and data between ( DATEADD (-EXTRACT(DAY FROM CURRENT_DATE)+1 DAY TO CURRENT_DATE) ) and (cast(current_date as date) - extract(day from cast(current_date as date)) + 32 - "
          "extract(day from (cast(current_date as date) - extract(day from cast(current_date as date)) + 32)))",
    };

    try {
      final resp = await CafeApi.post('/query', data);
      final prodResp = ProducaoResponse.fromMap(
        jsonDecode(resp) as Map<String, dynamic>,
      );
      qtdProducaoMesAtual = prodResp.data[0].quantidade;
      // debugPrint('Mês Atual ${qtdProducaoMesAtual.toString()}');

      cards.add(
        CartaoModel(
          titulo: 'Mês Atual',
          color: Colors.deepPurple,
          subtitulo: 'Produção',
          valor: '0',
          total: qtdProducaoMesAtual.toString(),
          quantidade: '',
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  getProducaoMesAnterior() async {
    isLoading = true;
    final Map<String, Object> data = {
      'query':
          "select 'Anterior' as mes, coalesce(SUM(quantidade),0) as quantidade from kardex where operacao = 'Entrada PCP'  "
          "and data between DATEADD (-EXTRACT(DAY FROM (DATEADD (-EXTRACT(DAY FROM CURRENT_DATE)+1 DAY TO CURRENT_DATE) - 1))+1 DAY "
          "TO (DATEADD (-EXTRACT(DAY FROM CURRENT_DATE)+1 DAY TO CURRENT_DATE) - 1)) and cast((DATEADD (-EXTRACT(DAY FROM CURRENT_DATE)+1 DAY TO CURRENT_DATE) - 1) as date)"
          " - extract(day from cast((DATEADD (-EXTRACT(DAY FROM CURRENT_DATE)+1 DAY TO CURRENT_DATE) - 1) as date)) + 32 - "
          "extract(day from (cast((DATEADD (-EXTRACT(DAY FROM CURRENT_DATE)+1 DAY TO CURRENT_DATE) - 1) as date) - "
          "extract(day from cast((DATEADD (-EXTRACT(DAY FROM CURRENT_DATE)+1 DAY TO CURRENT_DATE) - 1) as date)) + 32))",
    };

    final resp = await CafeApi.post('/query', data);
    final prodResp = ProducaoResponse.fromMap(
      jsonDecode(resp) as Map<String, dynamic>,
    );
    qtdProducaoMesAnterior = prodResp.data[0].quantidade;
    cards.add(
      CartaoModel(
        titulo: 'Mês Anterior',
        color: Colors.deepPurple,
        subtitulo: 'Produção',
        valor: '0',
        total: qtdProducaoMesAnterior.toString(),
        quantidade: '',
      ),
    );
    isLoading = false;
    notifyListeners();
  }
}
