import 'package:flutter/material.dart';
import 'package:shop_blink/ui/screens/Login/login_screen.dart';
import 'package:shop_blink/ui/screens/companies_screens.dart';
import 'package:shop_blink/ui/screens/config_screen.dart';
import 'package:shop_blink/ui/screens/config_token_screen.dart';
import 'package:shop_blink/ui/screens/home_screen.dart';
import 'package:shop_blink/ui/screens/loading_screen.dart';
import 'package:shop_blink/ui/screens/salesmans_screens.dart';
import 'package:shop_blink/ui/screens/signup/signup_screen.dart';
import 'package:shop_blink/ui/screens/wellcome/welcome_screen.dart';

final Map<String, Widget Function(BuildContext context)> appRoutes = {
  LoadingScreen.routeName: (context) => const LoadingScreen(),
  WelcomeScreen.routeName: (context) => const WelcomeScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  SalesmansScreen.routeName: (context) => const SalesmansScreen(),
  CompaniesScreens.routeName: (context) => const CompaniesScreens(),
  ConfigTokenScreen.routeName: (context) => const ConfigTokenScreen(),
  ConfigScreen.routeName: (context) => const ConfigScreen(),
};
