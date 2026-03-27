import 'dart:convert';

import 'package:shop_blink/models/product.dart';

class Cart {
  String id;
  Product product;
  String tamanho;
  int quantidade;
  Cart({
    required this.id,
    required this.product,
    required this.tamanho,
    required this.quantidade,
  });

  Cart copyWith({
    String? id,
    Product? product,
    String? tamanho,
    int? quantidade,
  }) {
    return Cart(
      id: id ?? this.id,
      product: product ?? this.product,
      tamanho: tamanho ?? this.tamanho,
      quantidade: quantidade ?? this.quantidade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'tamanho': tamanho,
      'quantidade': quantidade,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'] ?? '',
      product: Product.fromMap(map['product']),
      tamanho: map['tamanho'] ?? '',
      quantidade: map['quantidade']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Cart.fromJson(String source) => Cart.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Cart(id: $id, product: $product, tamanho: $tamanho, quantidade: $quantidade)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Cart &&
        other.id == id &&
        other.product == product &&
        other.tamanho == tamanho &&
        other.quantidade == quantidade;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        product.hashCode ^
        tamanho.hashCode ^
        quantidade.hashCode;
  }
}

// List<Cart> cartList = [
//   Cart(
//       product: Product(
//         image: "assets/images/product_0.png",
//         title: "Long Sleeve Shirts",
//         price: 165,
//         tamanho: ['PP', 'P', 'M', 'G', 'GG'],
//       ),
//       tamanho: 'M',
//       quantidade: 2),
//   Cart(
//       product: Product(
//         image: "assets/images/product_2.png",
//         title: "Curved Hem Shirts",
//         price: 180,
//         tamanho: ['PP', 'P', 'M', 'G', 'GG'],
//       ),
//       tamanho: 'GG',
//       quantidade: 5),
// ];
