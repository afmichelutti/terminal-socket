import 'package:flutter/cupertino.dart';
import 'package:shop_blink/models/cart.dart';
import 'package:shop_blink/models/product.dart';
import 'package:uuid/uuid.dart';

class CartProvider extends ChangeNotifier {
  List<Cart> cartList = [];
  var uuid = const Uuid();
  int totalPecas = 0;
  double total = 0.0;
  GlobalKey navBarKey = GlobalKey();

  void addItemCart(Product product, int quantidade, String tamanho) {
    cartList.add(
      Cart(
        id: uuid.v4(),
        product: product,
        quantidade: quantidade,
        tamanho: tamanho,
      ),
    );
    calculaTotalPecas();
    calculaTotal();
    notifyListeners();
  }

  void clearCartList() {
    cartList.clear();
    notifyListeners();
  }

  void removeItemCart(String id) {
    cartList.removeWhere((item) => item.id == id);
    calculaTotalPecas();
    calculaTotal();
    notifyListeners();
  }

  void incrementCart(String id) {
    for (Cart item in cartList) {
      if (item.id == id) {
        item.quantidade++;
      }
    }
    calculaTotalPecas();
    calculaTotal();
    notifyListeners();
  }

  void decrementCart(String id) {
    for (Cart item in cartList) {
      if (item.id == id) {
        item.quantidade--;
      }
    }
    calculaTotalPecas();
    calculaTotal();
    notifyListeners();
  }

  void calculaTotalPecas() {
    totalPecas = 0;
    for (Cart item in cartList) {
      totalPecas = totalPecas + item.quantidade;
    }
    notifyListeners();
  }

  void calculaTotal() {
    total = 0.0;
    for (Cart item in cartList) {
      total = total + item.quantidade * item.product.price;
    }
    notifyListeners();
  }
}
