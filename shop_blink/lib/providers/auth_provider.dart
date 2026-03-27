import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shop_blink/api/shopp_api.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/models/response/auth_response.dart';
import 'package:shop_blink/models/response/company_response.dart';
import 'package:shop_blink/models/response/status_response.dart';
import 'package:shop_blink/models/response/user_auth_response.dart';
import 'package:shop_blink/models/user.dart';
import 'package:shop_blink/services/local_storage.dart';
import 'package:shop_blink/ui/screens/config_token_screen.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthProvider extends ChangeNotifier {
  User? user;

  AuthStatus authStatus = AuthStatus.checking;
  late Server server;
  String validToken = '';
  int validCompany = 0;
  bool isLoading = false;

  Future<void> getStatus() async {
    try {
      final token = LocalStorage.prefs.getString('token_socket') ?? '';
      ShoppAPI.configureDio(socket: true, token: token);
      final resp = await ShoppAPI.post('/status', {});
      final statusResponse = StatusResponse.fromJson(resp);
      server = statusResponse.data[0];
      validToken = token;
    } catch (e) {
      validToken = '';
      debugPrint(e.toString());
    }
  }

  Future<void> getCompany() async {
    try {
      final token = LocalStorage.prefs.getString('token_socket') ?? '';
      if (token.isEmpty) {
        return;
      }
      validCompany = LocalStorage.prefs.getInt('company') ?? 0;
      if (validCompany > 0) {
        return;
      }
      ShoppAPI.configureDio(socket: true, token: token);
      final Map<String, Object> data = {
        'query': "select first 1 loja_padrao from parametro ",
      };
      final resp = await ShoppAPI.post('/query', data);
      final companyResponse = CompanyResponse.fromJson(resp);
      validCompany = companyResponse.data[0];
      LocalStorage.prefs.setInt('company', companyResponse.data[0]);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateTokenLoja(String id, String token, int loja) async {
    try {
      final data = {'tokenSocket': token, 'loja': loja};
      ShoppAPI.configureDio(
        socket: false,
        token: LocalStorage.prefs.getString('token') ?? '',
      );
      final json = await ShoppAPI.put('/users/$id', data);
      final userResponse = UserAuthResponse.fromJson(json);
      user = userResponse.user;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      ShoppAPI.configureDio(socket: false);
      final data = {'email': email, 'password': password};
      final json = await ShoppAPI.post('/login', data);
      final authResponse = AuthResponse.fromJson(json);
      user = authResponse.user;
      await LocalStorage.prefs.setString('token', authResponse.token.token);
      authStatus = AuthStatus.authenticated;
      await getStatus();
      await getCompany();
      toasty(
        context,
        'Login efetuado com sucesso!',
        gravity: ToastGravity.TOP_RIGHT,
        bgColor: kPrimaryColor,
        textColor: Colors.white,
      );
      notifyListeners();
      return true;
    } catch (e) {
      authStatus = AuthStatus.notAuthenticated;
      user = null;
      await LocalStorage.prefs.setString('token', '');
      ShoppAPI.configureDio(socket: false);
      toasty(
        context,
        'Credenciais inválidas!',
        gravity: ToastGravity.TOP_RIGHT,
        bgColor: kErrorColor,
        textColor: Colors.white,
      );
      notifyListeners();
      return false;
    }

    // ShoppAPI.post('/login', data).then((response) {
    //   final authResponse = AuthResponse.fromJson(response);
    //   authStatus = AuthStatus.authenticated;
    //   user = authResponse.user;
    //   LocalStorage.prefs.setString('token', authResponse.token.token);
    //   ShoppAPI.configureDio(socket: false);
    //   toasty(context, 'Login efetuado com sucesso!',
    //       gravity: ToastGravity.TOP_RIGHT,
    //       bgColor: kPrimaryColor,
    //       textColor: Colors.white);

    //   Navigator.of(context).pushReplacementNamed(ConfigTokenScreen.routeName);
    //   notifyListeners();
    // }).catchError((error) {
    //   authStatus = AuthStatus.notAuthenticated;
    //   user = null;
    //   LocalStorage.prefs.setString('token', '');
    //   ShoppAPI.configureDio(socket: false);
    //   toasty(context, 'Credenciais inválidas!',
    //       gravity: ToastGravity.TOP_RIGHT,
    //       bgColor: kErrorColor,
    //       textColor: Colors.white);
    //   notifyListeners();
    // });
  }

  void logout() {
    authStatus = AuthStatus.notAuthenticated;
    user = null;
    LocalStorage.prefs.remove('token');
    notifyListeners();
  }

  register(BuildContext context, String nome, String email, String password) {
    final data = {'username': nome, 'email': email, 'password': password};

    ShoppAPI.configureDio(socket: false);
    ShoppAPI.post('/register', data)
        .then((json) {
          final authResponse = AuthResponse.fromJson(json);
          authStatus = AuthStatus.authenticated;
          user = authResponse.user;
          LocalStorage.prefs.setString('token', authResponse.token.token);
          ShoppAPI.configureDio(socket: false);
          toasty(
            context,
            'Usuário cadastrado com sucesso!',
            gravity: ToastGravity.TOP_RIGHT,
            bgColor: kPrimaryColor,
            textColor: Colors.white,
          );
          Navigator.of(
            context,
          ).pushReplacementNamed(ConfigTokenScreen.routeName);
          notifyListeners();
        })
        .catchError((e) {
          debugPrint(e);
          // toasty(context, e,
          toasty(
            context,
            'Nome ou e-mail já cadastrados!',
            gravity: ToastGravity.TOP_RIGHT,
            bgColor: kErrorColor,
            textColor: Colors.white,
          );
        });
  }

  Future<void> isAuthenticated() async {
    final token = LocalStorage.prefs.getString('token');
    if (token == null) {
      authStatus = AuthStatus.notAuthenticated;
      return;
    }
    try {
      ShoppAPI.configureDio(socket: false, token: token);
      final resp = await ShoppAPI.httpGet('/auth');
      final authResponse = UserAuthResponse.fromMap(resp);
      user = authResponse.user;
      authStatus = AuthStatus.authenticated;
      await getStatus();
      await getCompany();
      await LocalStorage.prefs.setString('token', token);
      notifyListeners();
    } catch (e) {
      authStatus = AuthStatus.notAuthenticated;
      notifyListeners();
    }
  }
}
