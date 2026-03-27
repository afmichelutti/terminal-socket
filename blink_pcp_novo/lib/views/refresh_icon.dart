import 'package:flutter/material.dart';
import 'package:painel_producao_blink/providers/ordens_provider.dart';
import 'package:provider/provider.dart';

class RefreshIcon extends StatelessWidget {
  const RefreshIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        // await Provider.of<OrdensProvider>(context, listen: false)
        //     .cleanCards();
        await Provider.of<OrdensProvider>(
          context,
          listen: false,
        ).getOrdensCorte('C');
        await Provider.of<OrdensProvider>(
          context,
          listen: false,
        ).getOrdensProducao('P');
        await Provider.of<OrdensProvider>(
          context,
          listen: false,
        ).getOrdensServico('S');
        await Provider.of<OrdensProvider>(
          context,
          listen: false,
        ).getProducaoMesAnterior();
        await Provider.of<OrdensProvider>(
          context,
          listen: false,
        ).getProducaoMesAtual();
      },
      icon: const Icon(Icons.refresh),
    );
  }
}
