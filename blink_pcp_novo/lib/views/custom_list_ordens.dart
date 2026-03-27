import 'package:flutter/material.dart';
import 'package:painel_producao_blink/helpers/colors.dart';
import 'package:painel_producao_blink/models/ordem.dart';
import 'package:date_format/date_format.dart';

import 'package:painel_producao_blink/providers/ordens_provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class CustomListOrdens extends StatelessWidget {
  const CustomListOrdens({Key? key, required this.ordens}) : super(key: key);
  final List<Ordem> ordens;
  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<OrdensProvider>(context).isLoading;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return (ordens.isNotEmpty)
          ? _ListOrdens(ordens: ordens)
          : const Center(child: Text('Não há itens para mostrar'));
    }
  }
}

class _ListOrdens extends StatelessWidget {
  const _ListOrdens({Key? key, required this.ordens}) : super(key: key);

  final List<Ordem> ordens;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: ScrollController(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      itemCount: ordens.length,
      itemBuilder: (_, int i) {
        final ordem = ordens[i];
        return CustomListItemTwo(
          tipo: ordem.tipo,
          nome: ordem.nome,
          observacao: ordem.observacao,
          dias: ordem.dias,
          produto: ordem.idProduto,
          quantidade: ordem.quantidade,
          celula: ordem.celula,
          previsaoEntrega: formatDate(ordem.prevEntrega, [
            dd,
            ' de ',
            M,
            ' de ',
            yyyy,
          ], locale: const PortugueseDateLocale()),
          emissao: formatDate(ordem.emissao, [
            dd,
            ' de ',
            M,
          ], locale: const PortugueseDateLocale()),
          ordem: ordem.ordem.toString(),
          pedido: ordem.pedido,
          nomeCliente: ordem.nomeCliente,
        );
      },
    );
  }
}

class _ArticleDescription extends StatelessWidget {
  const _ArticleDescription({
    Key? key,
    required this.tipo,
    required this.produto,
    required this.nome,
    required this.quantidade,
    required this.celula,
    required this.previsaoEntrega,
    required this.emissao,
    required this.ordem,
    required this.pedido,
    required this.observacao,
    required this.nomeCliente,
  }) : super(key: key);

  final String tipo;
  final String produto;
  final String nome;
  final int quantidade;
  final String celula;
  final String previsaoEntrega;
  final String emissao;
  final String ordem;
  final int pedido;
  final String observacao;
  final String nomeCliente;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.hardEdge,
                physics: const ClampingScrollPhysics(),
                child: Text(
                  '$produto - $nome',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              4.height,
              Row(
                children: [
                  Text(
                    '${quantidade.toString()} peças',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 640) const Spacer(),
                  if (MediaQuery.of(context).size.width > 640)
                    Text(
                      ' $ordem',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color.fromARGB(135, 18, 2, 22),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                ],
              ),
              if (pedido > 0) 4.height,
              if (pedido > 0)
                Text(
                  'Pedido: $pedido $nomeCliente',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 10.0, color: Colors.blue.shade900),
                ),
              4.height,
              Row(
                children: [
                  const Icon(Icons.cell_tower, color: Colors.black54, size: 12),
                  Text(
                    ' $celula',
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (observacao != '') 2.height,
              if (observacao != '')
                Text(
                  observacao.toLowerCase(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10.0,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomListItemTwo extends StatelessWidget {
  const CustomListItemTwo({
    Key? key,
    required this.tipo,
    required this.produto,
    required this.nome,
    required this.quantidade,
    required this.celula,
    required this.previsaoEntrega,
    required this.emissao,
    required this.dias,
    required this.ordem,
    required this.observacao,
    required this.nomeCliente,
    required this.pedido,
  }) : super(key: key);

  final String tipo;
  final String produto;
  final String nome;
  final int quantidade;
  final String celula;
  final String previsaoEntrega;
  final String emissao;
  final int dias;
  final String ordem;
  final int pedido;
  final String observacao;
  final String nomeCliente;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SizedBox(
            height: 98,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.6,
                  child: Container(
                    child: _dadosQuadro(),
                    decoration: BoxDecoration(
                      color:
                          (dias == 0)
                              ? const Color.fromARGB(255, 243, 132, 6)
                              : (dias < 0)
                              ? Colors.pink
                              : Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 2.0, 0.0),
                    child: _ArticleDescription(
                      tipo: tipo,
                      observacao: observacao,
                      nome: nome,
                      produto: produto,
                      quantidade: quantidade,
                      celula: celula,
                      previsaoEntrega: previsaoEntrega,
                      emissao: emissao,
                      ordem: ordem,
                      pedido: pedido,
                      nomeCliente: nomeCliente,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _dadosQuadro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (tipo.trim() == 'Produção')
                ? const Icon(Icons.factory_outlined, size: 36)
                : (tipo.trim() == 'Corte')
                ? const Icon(Icons.cut_outlined, size: 36)
                : const Icon(Icons.work_outline_rounded, size: 36),
            Column(
              children: [
                Text(
                  emissao,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 241, 231, 231),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                2.height,
                (dias == 0)
                    ? const Text(
                      'É hoje!',
                      style: TextStyle(color: Colors.black87, fontSize: 18),
                    )
                    : (dias < 0)
                    ? const Text(
                      'Atraso',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                    : const Text(
                      'Faltam',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                2.height,
                if (dias < 0)
                  Text(
                    '${(dias * -1).toString()} dias',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )
                else if (dias > 0)
                  Text(
                    '${dias.toString()} dias',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                const SizedBox(height: 5),
                Text(
                  previsaoEntrega,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 241, 231, 231),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
