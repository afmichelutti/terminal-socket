import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/providers/order_provider.dart';
import 'package:shop_blink/providers/salesman_provider.dart';
import 'package:shop_blink/ui/components/order_card.dart';
import 'package:shop_blink/ui/components/section_title.dart';
import 'package:shop_blink/ui/screens/empty_hist_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final orderProvider = context.read<OrderProvider>();
    final salesman = context.read<SalesmanProvider>().selectedSalesman;
    orderProvider.getOrders(salesman);
    orderProvider.getAmount(salesman);
  }

  Widget _buildSummarySection(OrderProvider orderProvider) {
    final currencyFormatter = NumberFormat('R\$ #,##0.00', 'pt_BR');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text('Total de peças: ${orderProvider.quantitySalesman}'),
          const Spacer(),
          Text(
            'Total: ${currencyFormatter.format(orderProvider.amountSalesman)}',
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final salesman = context.read<SalesmanProvider>().selectedSalesman;
        orderProvider.getOrders(salesman);
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orderProvider.orders.length,
        itemBuilder:
            (context, index) => OrderCard(order: orderProvider.orders[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.orders.isEmpty) {
          return const EmptyHistScreen();
        }

        return RefreshIndicator(
          onRefresh: () async {
            final salesman = context.read<SalesmanProvider>().selectedSalesman;
            orderProvider.getOrders(salesman);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Histórico de Compras'),
                  const SizedBox(height: 6),
                  _buildSummarySection(orderProvider),
                  const SizedBox(height: 6),
                  _buildOrdersList(orderProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
