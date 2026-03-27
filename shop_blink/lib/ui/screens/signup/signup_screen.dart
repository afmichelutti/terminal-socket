import 'package:flutter/material.dart';
import 'package:shop_blink/ui/screens/Signup/components/body.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  static const routeName = '/signup_screen';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Body());
  }
}
