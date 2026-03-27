import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/models/product.dart';
import 'package:shop_blink/providers/cart_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shop_blink/providers/product_provider.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _selectedIndex = 0;
  String _tamSelected = "";

  @override
  void initState() {
    final produtcsProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    int tamIndex = produtcsProvider.tamIndex;
    int maxIndex = widget.product.tamanho.length - 1;

    // Verifique se o índice está dentro dos limites
    if (tamIndex < 0 || tamIndex > maxIndex) {
      tamIndex = 0; // ou qualquer valor padrão desejado
    }

    _tamSelected = widget.product.tamanho[tamIndex];
    _selectedIndex = produtcsProvider.tamIndex;
    // debugPrint("TAMANHO SELECIONADO: $_tamSelected");
    // debugPrint("TAMANHO SELECIONADO: ${produtcsProvider.tamIndex}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.product.title.capitalizeFirstLetter()),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberFormat(
                    'R\$ #,##0.00',
                    'pt_BR',
                  ).format(widget.product.price),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                FaIcon(
                  FontAwesomeIcons.tags,
                  size: 18,
                  color: Colors.deepPurple.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.product.id,
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: SizedBox(
              height: 62,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.product.tamanho.length,
                itemBuilder:
                    (context, i) => SizedBox(
                      // color: Colors.amber,
                      height: 58,
                      child: ChoiceChip(
                        onSelected: ((value) {
                          setState(() {
                            if (value) {
                              _selectedIndex = i;
                              _tamSelected = widget.product.tamanho[i];
                            }
                          });
                        }),
                        elevation: 2,
                        pressElevation: 1,
                        shadowColor: const Color.fromARGB(255, 138, 151, 150),
                        backgroundColor: Colors.black38,
                        selected: (_selectedIndex == i),
                        labelStyle: const TextStyle(color: Colors.white),
                        selectedColor: Colors.deepPurple,
                        label: badges.Badge(
                          position: BadgePosition.topEnd(top: -20, end: -14),
                          showBadge: (widget.product.estoque[i] > 0),
                          badgeContent: Text(
                            widget.product.estoque[i].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          child: Text(widget.product.tamanho[i]),
                        ),
                      ),
                    ),
                separatorBuilder: (context, i) => const SizedBox(width: 6),
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addItemCart(widget.product, 1, _tamSelected);
                  // toasty(
                  //   context,
                  //   'Adicionado ao carrinho',
                  //   gravity: ToastGravity.TOP_LEFT,
                  // );
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
          // if (_openCard)
          //   Divider(
          //     color: Colors.black.withOpacity(0.3),
          //     indent: 8,
          //     endIndent: 8,
          //   ),
          // if (_openCard)
          //   AnimatedContainer(
          //     duration: const Duration(microseconds: 300),
          //     curve: Curves.easeInOut,
          //     child: Image.asset(widget.product.image),
          //   ),
        ],
      ),
    );
  }
}
