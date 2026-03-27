import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shop_blink/api/shopp_api.dart';
import 'package:shop_blink/models/response/salesman_response.dart';

import 'package:shop_blink/models/salesman.dart';
import 'package:shop_blink/services/local_storage.dart';

class SalesmanProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Salesman> salesmans = [];
  late Salesman selectedSalesman = Salesman(
    id: 0,
    nome: "Selecione um vendedor",
  );

  void getSalesmans() async {
    isLoading = true;
    notifyListeners();
    ShoppAPI.configureDio(
      socket: true,
      token: LocalStorage.prefs.getString('token_socket') ?? '',
    );
    final Map<String, Object> data = {
      'query':
          "select id, nome from vendint where coalesce(HAB_APP_VENDA,'N') = 'S' and id_loja = (select first 1 loja_padrao from parametro) order by nome",
      // "select * from vendint where strlen(nome) > 20 order by nome"
    };
    final resp = await ShoppAPI.post('/query', data);

    try {
      var jsonObj = json.decode(resp);
      var prettyJson = JsonEncoder.withIndent('  ').convert(jsonObj);
      debugPrint('Resposta da API (Vendedores) formatada:\n$prettyJson');
    } catch (e) {
      debugPrint('Erro ao formatar JSON: $e');
      debugPrint('Resposta da API (bruta): $resp');
    }

    final salesmansResponse = SalesmanResponse.fromJson(resp);
    salesmans.clear();
    salesmans.addAll(salesmansResponse.data);
    isLoading = false;
    notifyListeners();
  }

  void setSelectedSalesman(Salesman salesman) {
    selectedSalesman = salesman;
    notifyListeners();
  }
}
