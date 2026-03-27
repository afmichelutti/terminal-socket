import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/providers/cart_provider.dart';
import 'package:shop_blink/providers/product_provider.dart';
import 'package:shop_blink/ui/screens/cart_screen.dart';
import 'package:shop_blink/ui/screens/config_screen.dart';
import 'package:shop_blink/ui/screens/orders_screen.dart';
import 'package:shop_blink/ui/screens/product_screen.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  @override
  void initState() {
    // ShoppAPI.configureDio(socket: true);
    super.initState();
  }

  static const List<Widget> _optionSelected = <Widget>[
    ProductScreen(),
    CartScreen(),
    OrdersScreen(),
    ConfigScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final badget = Provider.of<CartProvider>(context).cartList.length;
    final produtcProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.withOpacity(0.4),
        // elevation: 0,
        // ignore: prefer_const_constructors
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(width: defaultPadding / 2),
            Text('Shop VisualControl', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Map<Permission, PermissionStatus> statuses =
                  await [Permission.camera, Permission.storage].request();
              if (statuses[Permission.camera] != PermissionStatus.granted) {
                return;
              }
              if (mounted) return produtcProvider.scanBarcodeNormal(context);
            },
            icon: const Icon(Icons.qr_code_scanner_outlined),
          ),
        ],
      ),
      body: SafeArea(child: _optionSelected.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: (badget > 0),
              badgeContent: Text(
                badget.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Carrinho',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: 'Histórico',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.engineering_outlined),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}
