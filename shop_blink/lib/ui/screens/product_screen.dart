import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/providers/product_provider.dart';
import 'package:shop_blink/providers/salesman_provider.dart';
import 'package:shop_blink/ui/components/product_list.dart';
import 'package:shop_blink/ui/components/search_form.dart';
import 'package:shop_blink/ui/components/section_title.dart';
import 'package:shop_blink/ui/widgets/custom_loading.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    Provider.of<ProductProvider>(context, listen: false).getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<ProductProvider>(context).isLoading;
    final productsProvider = Provider.of<ProductProvider>(context);
    final products = productsProvider.products;

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Olá, ${Provider.of<SalesmanProvider>(context, listen: false).selectedSalesman.nome.capitalizeFirstLetter()}',
                    style: primaryTextStyle(
                      color: Colors.deepPurple,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SearchForm(),
            ],
          ),
          const SizedBox(height: 6),
          SectionTitle(
            title:
                (products.isNotEmpty)
                    ? 'Produtos (${products.length})'
                    : 'Produtos',
            onPressed: () {},
          ),
          const SizedBox(height: 6),
          (isLoading)
              ? const CustomLoading(title: 'Carregando Produtos...')
              : const Expanded(child: ProductList()),
        ],
      ),
    );
  }
}
