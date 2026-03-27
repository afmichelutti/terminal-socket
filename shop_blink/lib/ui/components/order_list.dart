import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/providers/order_provider.dart';
import 'package:shop_blink/providers/salesman_provider.dart';
import 'package:shop_blink/ui/components/order_card.dart';

class OrderList extends StatelessWidget {
  const OrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            final salesman = context.read<SalesmanProvider>().selectedSalesman;
            orderProvider.getOrders(salesman);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: orderProvider.orders.length,
            itemBuilder:
                (context, index) =>
                    OrderCard(order: orderProvider.orders[index]),
          ),
        );
      },
    );
  }
}
