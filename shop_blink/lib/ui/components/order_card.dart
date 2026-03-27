import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/models/order.dart';
import 'package:shop_blink/providers/order_provider.dart';
import 'package:shop_blink/ui/components/order_items_list.dart';
import 'package:shop_blink/ui/screens/order_sharing.dart';
import 'package:shop_blink/ui/widgets/custom_loading.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderCard extends StatefulWidget {
  const OrderCard({super.key, required this.order});
  final Order order;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _openCard = false;
  bool _isLoadingShare = false;

  _toogleCard() {
    setState(() {
      _openCard = !_openCard;
      if (_openCard) {
        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).getOrderItems(widget.order.id);
      }
    });
  }

  void _showShareOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Compartilhar Pedido'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('PDF'),
                  onTap: () => _handleShare(true),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.text_snippet,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Texto'),
                  onTap: () => _handleShare(false),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _handleShare(bool isPdf) async {
    Navigator.pop(context);

    setState(() => _isLoadingShare = true);

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final completeOrder = await orderProvider.getOrder(widget.order.id);

      if (completeOrder == null) {
        throw Exception('Não foi possível carregar os dados do pedido');
      }

      if (isPdf) {
        await OrderSharing.shareAsPdf(completeOrder);
      } else {
        await OrderSharing.shareAsText(completeOrder);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPdf
                  ? 'Erro ao gerar PDF. Tente novamente.'
                  : 'Erro ao compartilhar. Tente novamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingShare = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<OrderProvider>(context).isLoading;
    final orderItems = Provider.of<OrderProvider>(context).orderItems;
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        children: [
          ListTile(
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoadingShare
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      color: Colors.deepPurple,
                      onPressed: _showShareOptions,
                    ),
                _openCard
                    ? IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up_outlined),
                      onPressed: _toogleCard,
                    )
                    : IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                      onPressed: _toogleCard,
                    ),
              ],
            ),
            // Resto do ListTile permanece igual
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.salesman.capitalizeFirstLetter(),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatDate(
                          widget.order.dataCom,
                          [dd, ' de ', M, ', ', HH, ':', nn],
                          locale: const PortugueseDateLocale(),
                        ),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.order.codigo.toString(),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Text(
                  NumberFormat(
                    'R\$ #,##0.00',
                    'pt_BR',
                  ).format(widget.order.amount),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                (widget.order.quantidade > 1)
                    ? Text(
                      '${widget.order.quantidade.toString()} peças',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    )
                    : Text(
                      '${widget.order.quantidade.toString()} peça',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
              ],
            ),
          ),
          if (_openCard)
            Divider(
              color: Colors.black.withOpacity(0.3),
              indent: 8,
              endIndent: 8,
            ),
          if (_openCard)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                color: Colors.white,
                height: 160,
                width: double.infinity,
                child:
                    (isLoading)
                        ? const CustomLoading(title: 'Carregando itens')
                        : OrderItemsList(orderItems: orderItems),
              ),
            ),
        ],
      ),
    );
  }
}
