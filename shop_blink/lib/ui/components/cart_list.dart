import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/providers/cart_provider.dart';
import 'package:shop_blink/ui/components/cart_card.dart';

class CartList extends StatefulWidget {
  const CartList({Key? key}) : super(key: key);

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartList = Provider.of<CartProvider>(context).cartList;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: cartList.length,
      itemBuilder: (context, index) => CardCart(cart: cartList[index]),
    );
  }
}
