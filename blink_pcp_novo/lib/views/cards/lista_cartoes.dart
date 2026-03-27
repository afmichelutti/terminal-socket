import 'package:flutter/material.dart';
import 'package:painel_producao_blink/providers/ordens_provider.dart';
import 'package:painel_producao_blink/views/cards/cartao_widget.dart';
import 'package:provider/provider.dart';

class ListaCartoes extends StatefulWidget {
  const ListaCartoes({super.key});

  @override
  State<ListaCartoes> createState() => _ListaCartoesState();
}

class _ListaCartoesState extends State<ListaCartoes> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cards = Provider.of<OrdensProvider>(context).cards;
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder:
                  (_, i) =>
                      (cards[i].color == Colors.deepPurple)
                          ? CartaoWidget(cartao: cards[i], color: Colors.white)
                          : CartaoWidget(cartao: cards[i], color: Colors.black),
              separatorBuilder: (_, i) => const SizedBox(width: 15),
              itemCount: cards.length,
            ),
          ),
        ],
      ),
    );
  }
}
