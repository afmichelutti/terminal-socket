import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/models/salesman.dart';
import 'package:shop_blink/providers/cart_provider.dart';
import 'package:shop_blink/providers/order_provider.dart';
import 'package:shop_blink/providers/salesman_provider.dart';
import 'package:shop_blink/ui/components/cart_list.dart';
import 'package:shop_blink/ui/components/section_title.dart';
import 'package:shop_blink/ui/screens/empty_cart_screen.dart';
import 'package:shop_blink/ui/screens/salesmans_screens.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartList = Provider.of<CartProvider>(context).cartList;
    final _totalPecas = Provider.of<CartProvider>(context).totalPecas;
    final _total = Provider.of<CartProvider>(context).total;
    final _isSaving = Provider.of<OrderProvider>(context).isSaving;

    void _insertOrder() async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final Salesman salesman =
          Provider.of<SalesmanProvider>(
            context,
            listen: false,
          ).selectedSalesman;
      await Provider.of<OrderProvider>(context, listen: false).saveOrder(
        context,
        cartList,
        _totalPecas,
        _total,
        salesman,
        cartProvider,
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        SalesmansScreen.routeName,
        (Route<dynamic> route) => false,
      );
    }

    return (cartList.isNotEmpty)
        ? Padding(
          // padding: const EdgeInsets.all(defaultPadding),
          padding: const EdgeInsets.only(
            top: 16,
            right: 16,
            bottom: 2,
            left: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SectionTitle(title: 'Carrinho de Compras'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).clearCartList();
                    },
                    child: const Text(
                      'Limpar',
                      style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Expanded(child: CartList()),
              Container(
                padding: const EdgeInsets.only(top: 2),
                height: 95,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          // color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 0.6,
                          ),
                          // color: Colors.amber,
                        ),
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.89,
                        // color: Colors.amber,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                '$_totalPecas peças',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                NumberFormat(
                                  'R\$ #,##0.00',
                                  'pt_BR',
                                ).format(_total),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.only(bottom: 4),
                      height: 44,
                      width: MediaQuery.of(context).size.width * 0.89,
                      child:
                          (!_isSaving)
                              ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  // Foreground color
                                  foregroundColor: Colors.white,
                                  // Background color
                                  backgroundColor: Colors.deepPurple,
                                ).copyWith(
                                  elevation: ButtonStyleButton.allOrNull(0.0),
                                ),
                                onPressed: _insertOrder,
                                child: const Text('Finalizar'),
                              )
                              : const SizedBox(
                                height: 40,
                                width: 40,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        : const EmptyCartScreen();
  }
}
