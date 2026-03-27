import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/api/config/environment.dart';
import 'package:shop_blink/api/shopp_api.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/providers/provider.dart';
import 'package:shop_blink/routes/routes.dart';
import 'package:shop_blink/services/enum.dart';
import 'package:shop_blink/services/local_storage.dart';
import 'package:shop_blink/ui/screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  EnvironmentConfig.environmentBuild = Environments.production;
  await LocalStorage.configurePrefs();
  ShoppAPI.configureDio(socket: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shopp APP',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: bgColor,
          fontFamily: "Gordita",
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black54),
          ),
        ),
        initialRoute: LoadingScreen.routeName,
        routes: appRoutes,
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
