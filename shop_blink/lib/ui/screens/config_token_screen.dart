import 'package:flutter/material.dart';
import 'package:shop_blink/ui/components/section_title.dart';
import 'package:shop_blink/ui/components/token_form.dart';

class ConfigTokenScreen extends StatelessWidget {
  const ConfigTokenScreen({Key? key}) : super(key: key);
  static const routeName = '/config_token_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Configurar token'),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SectionTitle(title: 'Configuração do Token do Servidor'),
                SizedBox(height: 12),
                Text(
                  'Informe o token de acesso ao servidor do VisualControl. Este token de acesso deverá ser obtido no servidor do VisualControl',
                ),
                SizedBox(height: 12),
                TokenForm(),
                SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
