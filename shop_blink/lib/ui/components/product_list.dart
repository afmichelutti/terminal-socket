import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_blink/providers/product_provider.dart';
import 'package:shop_blink/ui/components/product_card.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});
  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context).products;
    return (products.isNotEmpty)
        ? ListView.builder(
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        )
        : const Center(child: Text('Não há produtos na pesquisa.'));
  }
}
