import 'package:flutter/material.dart';
import 'package:painel_producao_blink/providers/ordens_provider.dart';
import 'package:provider/provider.dart';

class CustomSearchOrdem extends StatelessWidget {
  const CustomSearchOrdem({
    Key? key,
    required TextEditingController textController,
  }) : _textController = textController,
       super(key: key);

  final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    final ordemProvider = Provider.of<OrdensProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 80,
        child: TextField(
          controller: _textController,
          onChanged: (value) {
            ordemProvider.findProducao(_textController.text);
            ordemProvider.findCorte(_textController.text);
            ordemProvider.findServico(_textController.text);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
            hintText: 'Pesquisar',
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 98, 107, 163).withOpacity(0.9),
              ),
            ),
            prefixIcon: const Icon(Icons.search_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                _textController.text = '';
                ordemProvider.clearSearch();
              },
              icon: const Icon(Icons.clear_outlined),
            ),
          ),
        ),
      ),
    );
  }
}
