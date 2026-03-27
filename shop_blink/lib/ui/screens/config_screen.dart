import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/api/config/environment.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/providers/auth_provider.dart';
import 'package:shop_blink/services/enum.dart';
import 'package:shop_blink/services/local_storage.dart';
import 'package:shop_blink/ui/components/section_title.dart';
import 'package:shop_blink/ui/screens/wellcome/welcome_screen.dart';

class ConfigScreen extends StatelessWidget {
  static const routeName = '/config_page';
  const ConfigScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SectionTitle(title: 'Configurações'),
              const Spacer(),
              TextButton(
                onLongPress: () {
                  LocalStorage.prefs.clear();
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    WelcomeScreen.routeName,
                    (Route<dynamic> route) => false,
                  );
                },
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(WelcomeScreen.routeName);
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                ),
              ),
              if (EnvironmentConfig.environmentBuild == Environments.developer)
                TextButton(
                  onPressed: () {
                    LocalStorage.prefs.clear();
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(WelcomeScreen.routeName);
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                  ),
                ),
            ],
          ),
          16.height,
          const Text(
            'Token Configurado',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            LocalStorage.prefs.getString('token_socket') ?? 'Nenhuma chave',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.deepPurple,
            ),
          ),
          16.height,
          Text(
            'Loja ${LocalStorage.prefs.getInt('company').toString()} configurada ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
