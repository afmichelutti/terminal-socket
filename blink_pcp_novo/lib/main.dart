import 'package:flutter/material.dart';
import 'package:painel_producao_blink/api/cafe_api.dart';
import 'package:painel_producao_blink/config/environment.dart';
import 'package:painel_producao_blink/helpers/constants.dart';
import 'package:painel_producao_blink/providers/ordens_provider.dart';
import 'package:painel_producao_blink/services/local_storage.dart';
import 'package:painel_producao_blink/views/cards/lista_cartoes.dart';
import 'package:painel_producao_blink/views/custom_search_ordem.dart';
import 'package:painel_producao_blink/views/painel_ordens.dart';
import 'package:painel_producao_blink/views/refresh_icon.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

void main() async {
  EnvironmentConfig.environmentBuild = Environments.developer;
  await LocalStorage.configurePrefs();
  CafeApi.configureDio();
  runApp(const AppState());
}

/// This is the main application widget.
class AppState extends StatelessWidget {
  const AppState({super.key});

  static const String _title = 'Painel de Controle de PCP';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OrdensProvider>(
          create: (context) => OrdensProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          iconTheme: const IconThemeData(size: 36.0, color: Colors.white),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
          ),
        ),
        title: _title,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(_title),
            actions: [
              const RefreshIcon(),
              PopupMenuButton(
                itemBuilder: (context) {
                  return Constants.choices.map((e) {
                    return PopupMenuItem(
                      child: Text(e, style: primaryTextStyle()),
                      onTap:
                          () => {
                            if (e == Constants.soObservacao)
                              {
                                Provider.of<OrdensProvider>(
                                  context,
                                  listen: false,
                                ).findObservacao(),
                              }
                            else if (e == Constants.soPedidos)
                              {
                                Provider.of<OrdensProvider>(
                                  context,
                                  listen: false,
                                ).findPedidos(),
                              }
                            else if (e == Constants.todos)
                              {
                                Provider.of<OrdensProvider>(
                                  context,
                                  listen: false,
                                ).clearSearch(),
                              },
                          },
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: const MyBody(),
        ),
      ),
    );
  }
}

class MyBody extends StatefulWidget {
  const MyBody({Key? key}) : super(key: key);

  @override
  State<MyBody> createState() => _MyBodyState();
}

class _MyBodyState extends State<MyBody> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    // Provider.of<OrdensProvider>(context, listen: false).clearTotalPecasSearch();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordemProvider = Provider.of<OrdensProvider>(context);
    final qtdTotal =
        ordemProvider.totalPecasSearchCorte +
        ordemProvider.totalPecasSearchProducao +
        ordemProvider.totalPecasSearchServico;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 25, bottom: 10),
          child: CustomSearchOrdem(textController: _textController),
        ),
        if (qtdTotal > 0)
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 10),
            child: Text(
              'Total de peças: ${qtdTotal.toString()}',
              style: primaryTextStyle(),
            ),
          ),
        const ListaCartoes(),
        const Expanded(child: PainelOrdens()),
      ],
    );
  }
}
