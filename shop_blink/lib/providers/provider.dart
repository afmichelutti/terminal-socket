import 'package:provider/provider.dart';
import 'package:shop_blink/providers/auth_provider.dart';

import 'package:shop_blink/providers/cart_provider.dart';
import 'package:shop_blink/providers/company_provider.dart';
import 'package:shop_blink/providers/order_provider.dart';
import 'package:shop_blink/providers/product_provider.dart';
import 'package:shop_blink/providers/salesman_provider.dart';

final providers = [
  ChangeNotifierProvider<AuthProvider>(
    // lazy: false,
    create: (_) => AuthProvider(),
  ),
  ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
  ChangeNotifierProvider<ProductProvider>(
    // lazy: false,
    create: (context) => ProductProvider(context.read<CartProvider>()),
  ),
  ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
  ChangeNotifierProvider<CompanyProvider>(create: (_) => CompanyProvider()),
  ChangeNotifierProvider<SalesmanProvider>(create: (_) => SalesmanProvider()),
];
