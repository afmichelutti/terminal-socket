import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shop_blink/models/order_item.dart';

class OrderItemsList extends StatelessWidget {
  final List<OrderItem> orderItems;

  const OrderItemsList({Key? key, required this.orderItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: orderItems.length,
      itemBuilder:
          (context, index) => ListTile(
            title: Row(
              children: [
                Text('${index + 1}. ', style: secondaryTextStyle()),
                Expanded(
                  child: Text(
                    orderItems[index].nomeproduto.capitalizeFirstLetter(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: secondaryTextStyle(),
                  ),
                ),
                // const Spacer(),
                Text(
                  NumberFormat(
                    'R\$ #,##0.00',
                    'pt_BR',
                  ).format(orderItems[index].price),
                  style: secondaryTextStyle(),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Text(
                  'Tam: ${orderItems[index].tamanho}',
                  style: secondaryTextStyle(),
                ),
                const Spacer(),
                Text(
                  '${orderItems[index].quantidade.toString()} peça(s)',
                  style: secondaryTextStyle(),
                ),
              ],
            ),
          ),
    );
  }
}
