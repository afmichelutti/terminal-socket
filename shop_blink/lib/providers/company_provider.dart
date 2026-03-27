import 'package:flutter/material.dart';
import 'package:shop_blink/api/shopp_api.dart';
import 'package:shop_blink/models/company.dart';
import 'package:shop_blink/models/response/companies_response.dart';
import 'package:shop_blink/services/local_storage.dart';

class CompanyProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Company> companies = [];

  void getCompanies(String token) async {
    isLoading = true;
    notifyListeners();
    ShoppAPI.configureDio(
      socket: true,
      token: LocalStorage.prefs.getString('token_socket') ?? '',
    );
    final Map<String, Object> data = {
      'query':
          "select id, nome as name, nome_fant as fantasy, cpfcgc as cnpj, token_socket from loja where status <> 'C' and token_socket is not null order by nome",
    };
    final resp = await ShoppAPI.post('/query', data);
    final companiesReponse = CompaniesReponse.fromJson(resp);
    companies.clear();
    companies.addAll(companiesReponse.data);
    final selected = LocalStorage.prefs.getInt('company') ?? 0;
    if (selected > 0) {
      selectCompany(selected);
    }
    isLoading = false;
    notifyListeners();
  }

  void selectCompany(int id) {
    for (Company cp in companies) {
      if (cp.id == id) {
        cp.selected = true;
      } else {
        cp.selected = false;
      }
    }
    notifyListeners();
    LocalStorage.prefs.setInt('company', id);
  }
}
