import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/models/cart.dart';
import 'package:shop_blink/providers/cart_provider.dart';

class CardCart extends StatefulWidget {
  const CardCart({Key? key, required this.cart}) : super(key: key);
  final Cart cart;

  @override
  State<CardCart> createState() => _CardCartState();
}

class _CardCartState extends State<CardCart> {
  _remove() {
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).removeItemCart(widget.cart.id);
  }

  _increment() {
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).incrementCart(widget.cart.id);
  }

  _decrement() {
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).decrementCart(widget.cart.id);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.cart.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            _remove();
          },
        ),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            onPressed: (context) => _remove(),
            backgroundColor: const Color.fromARGB(255, 240, 95, 95),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title:
                // inserir title of products and codigo
                Text(widget.cart.product.title.capitalizeFirstLetter()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          labelStyle: const TextStyle(color: Colors.white),
                          backgroundColor: Colors.deepPurple.withOpacity(0.8),
                          label: Text(
                            widget.cart.tamanho,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          NumberFormat(
                            'R\$ #,##0.00',
                            'pt_BR',
                          ).format(widget.cart.product.price),
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Ref.: ',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.cart.product.id,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (widget.cart.quantidade > 0)
                    ? IconButton(
                      alignment: Alignment.topCenter,
                      onPressed: _decrement,
                      icon: Icon(
                        Icons.remove_circle,
                        size: 24,
                        color: Colors.deepPurple.withOpacity(0.9),
                      ),
                    )
                    : IconButton(
                      alignment: Alignment.topCenter,
                      onPressed: _remove,
                      icon: const Icon(
                        Icons.delete_outlined,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                // const SizedBox(width: 2),
                Text(
                  widget.cart.quantidade.toString(),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SizedBox(width: 2),
                IconButton(
                  alignment: Alignment.topCenter,
                  onPressed: _increment,
                  icon: Icon(
                    Icons.add_circle,
                    size: 24,
                    color: Colors.deepPurple.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
