import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/providers/auth_provider.dart';
import 'package:shop_blink/ui/screens/home_screen.dart';
import 'package:shop_blink/ui/screens/wellcome/components/body.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  static const routeName = '/wellcome_screen';

  @override
  Widget build(BuildContext context) {
    final authStatus =
        Provider.of<AuthProvider>(context, listen: false).authStatus;
    // print(authStatus.toString());
    return Scaffold(
      body:
          (authStatus == AuthStatus.authenticated)
              ? const HomeScreen()
              : const Body(),
    );
  }
}
