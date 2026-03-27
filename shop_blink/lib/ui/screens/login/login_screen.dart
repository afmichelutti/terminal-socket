import 'package:flutter/material.dart';
import 'package:shop_blink/ui/screens/Login/components/body.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login_screen';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Body());
  }
}
