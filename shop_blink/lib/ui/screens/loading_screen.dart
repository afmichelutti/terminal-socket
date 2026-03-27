import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/providers/auth_provider.dart';
import 'package:shop_blink/ui/screens/config_token_screen.dart';
import 'package:shop_blink/ui/screens/salesmans_screens.dart';
import 'package:shop_blink/ui/screens/wellcome/welcome_screen.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  static const routeName = '/loading_page';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginStatus(context),
        builder: (ctx, snap) {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future checkLoginStatus(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.isAuthenticated();
    final validToken = authProvider.validToken;
    if (authProvider.authStatus == AuthStatus.authenticated) {
      if (validToken.isEmpty) {
        return Navigator.pushReplacementNamed(
          context,
          ConfigTokenScreen.routeName,
        );
      }
      return Navigator.of(context).pushNamedAndRemoveUntil(
        SalesmansScreen.routeName,
        (Route<dynamic> route) => false,
      );
    }
    return Navigator.of(context).pushReplacementNamed(WelcomeScreen.routeName);
  }
}
