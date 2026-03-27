import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painel_producao_blink/models/cartoes.dart';
import 'package:nb_utils/nb_utils.dart';

class CartaoWidget extends StatelessWidget {
  const CartaoWidget({
    Key? key,
    required this.cartao,
    this.color = Colors.black,
  }) : super(key: key);

  final CartaoModel cartao;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 182),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: cartao.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(cartao.titulo, style: boldTextStyle(size: 18, color: color)),
          3.height,
          Text(
            cartao.subtitulo,
            style: primaryTextStyle(size: 12, color: color),
          ),
          3.height,
          if (cartao.valor != '0')
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cartao.valor,
                  style: primaryTextStyle(size: 12, color: color),
                ),
                Text(
                  ' - Qt: ${NumberFormat('#,##0', 'pt_BR').format(int.tryParse(cartao.quantidade))}',
                  style: primaryTextStyle(size: 12, color: color),
                ),
              ],
            ),
          3.height,
          Text(cartao.total, style: boldTextStyle(size: 12, color: color)),
        ],
      ),
    );
  }
}
