import 'package:flutter/material.dart';
import 'package:painel_producao_blink/providers/ordens_provider.dart';
import 'package:painel_producao_blink/views/custom_list_ordens.dart';
import 'package:provider/provider.dart';

class PainelOrdens extends StatefulWidget {
  const PainelOrdens({super.key});

  @override
  State<PainelOrdens> createState() => _PainelOrdensState();
}

class _PainelOrdensState extends State<PainelOrdens> {
  _loadOrders() async {
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
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final ordensCorte = Provider.of<OrdensProvider>(context).ordensCorte;
    final ordensServico = Provider.of<OrdensProvider>(context).ordensServico;
    final ordensProducao = Provider.of<OrdensProvider>(context).ordensProducao;
    final fordensProducao =
        Provider.of<OrdensProvider>(context).fordensProducao;
    final fordensCorte = Provider.of<OrdensProvider>(context).fordensCorte;
    final fordensServico = Provider.of<OrdensProvider>(context).fordensServico;
    final bool searching = Provider.of<OrdensProvider>(context).searching;

    return Row(
      children: [
        Expanded(
          child: CustomListOrdens(
            ordens:
                (fordensCorte.isNotEmpty || searching)
                    ? fordensCorte
                    : ordensCorte,
          ),
        ),
        Expanded(
          child: CustomListOrdens(
            ordens:
                (fordensServico.isNotEmpty || searching)
                    ? fordensServico
                    : ordensServico,
          ),
        ),
        Expanded(
          child: CustomListOrdens(
            ordens:
                (fordensProducao.isNotEmpty || searching)
                    ? fordensProducao
                    : ordensProducao,
          ),
        ),
      ],
    );
  }
}
