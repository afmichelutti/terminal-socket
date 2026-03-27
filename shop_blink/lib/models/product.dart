import 'dart:convert';

import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String image;
  final String title;
  final double price;
  List<String> tamanho;
  List<int> estoque;
  final String? tam01;
  final String? tam02;
  final String? tam03;
  final String? tam04;
  final String? tam05;
  final String? tam06;
  final String? tam07;
  final String? tam08;
  final String? tam09;
  final String? tam10;
  final String? tam11;
  final String? tam12;
  final String? tam13;
  final String? tam14;
  final String? tam15;

  final int? e01;
  final int? e02;
  final int? e03;
  final int? e04;
  final int? e05;
  final int? e06;
  final int? e07;
  final int? e08;
  final int? e09;
  final int? e10;
  final int? e11;
  final int? e12;
  final int? e13;
  final int? e14;
  final int? e15;

  Product({
    required this.id,
    required this.image,
    required this.title,
    required this.price,
    this.tamanho = const ['Qtd'],
    this.estoque = const [0],
    this.tam01,
    this.tam02,
    this.tam03,
    this.tam04,
    this.tam05,
    this.tam06,
    this.tam07,
    this.tam08,
    this.tam09,
    this.tam10,
    this.tam11,
    this.tam12,
    this.tam13,
    this.tam14,
    this.tam15,
    this.e01,
    this.e02,
    this.e03,
    this.e04,
    this.e05,
    this.e06,
    this.e07,
    this.e08,
    this.e09,
    this.e10,
    this.e11,
    this.e12,
    this.e13,
    this.e14,
    this.e15,
  });

  Product copyWith({
    String? id,
    String? image,
    String? title,
    double? price,
    List<String>? tamanho,
    List<int>? estoque,
    String? tam01,
    String? tam02,
    String? tam03,
    String? tam04,
    String? tam05,
    String? tam06,
    String? tam07,
    String? tam08,
    String? tam09,
    String? tam10,
    String? tam11,
    String? tam12,
    String? tam13,
    String? tam14,
    String? tam15,
    int? e01,
    int? e02,
    int? e03,
    int? e04,
    int? e05,
    int? e06,
    int? e07,
    int? e08,
    int? e09,
    int? e10,
    int? e11,
    int? e12,
    int? e13,
    int? e14,
    int? e15,
  }) {
    return Product(
      id: id ?? this.id,
      image: image ?? this.image,
      title: title ?? this.title,
      price: price ?? this.price,
      tamanho: tamanho ?? this.tamanho,
      estoque: estoque ?? this.estoque,
      tam01: tam01 ?? this.tam01,
      tam02: tam02 ?? this.tam02,
      tam03: tam03 ?? this.tam03,
      tam04: tam04 ?? this.tam04,
      tam05: tam05 ?? this.tam05,
      tam06: tam06 ?? this.tam06,
      tam07: tam07 ?? this.tam07,
      tam08: tam08 ?? this.tam08,
      tam09: tam09 ?? this.tam09,
      tam10: tam10 ?? this.tam10,
      tam11: tam11 ?? this.tam11,
      tam12: tam12 ?? this.tam12,
      tam13: tam13 ?? this.tam13,
      tam14: tam14 ?? this.tam14,
      tam15: tam15 ?? this.tam15,
      e01: e01 ?? this.e01,
      e02: e02 ?? this.e02,
      e03: e03 ?? this.e03,
      e04: e04 ?? this.e04,
      e05: e05 ?? this.e05,
      e06: e06 ?? this.e06,
      e07: e07 ?? this.e07,
      e08: e08 ?? this.e08,
      e09: e09 ?? this.e09,
      e10: e10 ?? this.e10,
      e11: e11 ?? this.e11,
      e12: e12 ?? this.e12,
      e13: e13 ?? this.e13,
      e14: e14 ?? this.e14,
      e15: e15 ?? this.e15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'price': price,
      'tamanho': tamanho,
      'estoque': estoque,
      'tam01': tam01,
      'tam02': tam02,
      'tam03': tam03,
      'tam04': tam04,
      'tam05': tam05,
      'tam06': tam06,
      'tam07': tam07,
      'tam08': tam08,
      'tam09': tam09,
      'tam10': tam10,
      'tam11': tam11,
      'tam12': tam12,
      'tam13': tam13,
      'tam14': tam14,
      'tam15': tam15,
      'e01': e01,
      'e02': e02,
      'e03': e03,
      'e04': e04,
      'e05': e05,
      'e06': e06,
      'e07': e07,
      'e08': e08,
      'e09': e09,
      'e10': e10,
      'e11': e11,
      'e12': e12,
      'e13': e13,
      'e14': e14,
      'e15': e15,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    List<String> tam = [];
    List<int> e = [];
    if (map['tam01'].isNotEmpty) {
      tam.add(map['tam01']);
    }
    if (map['tam02'].isNotEmpty) {
      tam.add(map['tam02']);
    }
    if (map['tam03'].isNotEmpty) {
      tam.add(map['tam03']);
    }
    if (map['tam04'].isNotEmpty) {
      tam.add(map['tam04']);
    }
    if (map['tam05'].isNotEmpty) {
      tam.add(map['tam05']);
    }
    if (map['tam06'].isNotEmpty) {
      tam.add(map['tam06']);
    }
    if (map['tam07'].isNotEmpty) {
      tam.add(map['tam07']);
    }
    if (map['tam08'].isNotEmpty) {
      tam.add(map['tam08']);
    }
    if (map['tam09'].isNotEmpty) {
      tam.add(map['tam09']);
    }
    if (map['tam10'].isNotEmpty) {
      tam.add(map['tam10']);
    }
    if (map['tam11'].isNotEmpty) {
      tam.add(map['tam11']);
    }
    if (map['tam12'].isNotEmpty) {
      tam.add(map['tam12']);
    }
    if (map['tam13'].isNotEmpty) {
      tam.add(map['tam13']);
    }
    if (map['tam14'].isNotEmpty) {
      tam.add(map['tam14']);
    }
    if (map['tam15'].isNotEmpty) {
      tam.add(map['tam15']);
    }
    e.add(map['e01']);
    e.add(map['e02']);
    e.add(map['e03']);
    e.add(map['e04']);
    e.add(map['e05']);
    e.add(map['e06']);
    e.add(map['e07']);
    e.add(map['e08']);
    e.add(map['e09']);
    e.add(map['e10']);
    e.add(map['e11']);
    e.add(map['e12']);
    e.add(map['e13']);
    e.add(map['e14']);
    e.add(map['e15']);

    return Product(
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      title: map['title'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      tamanho: tam,
      estoque: e,
      tam01: map['tam01'] ?? '',
      tam02: map['tam02'] ?? '',
      tam03: map['tam03'] ?? '',
      tam04: map['tam04'] ?? '',
      tam05: map['tam05'] ?? '',
      tam06: map['tam06'] ?? '',
      tam07: map['tam07'] ?? '',
      tam08: map['tam08'] ?? '',
      tam09: map['tam09'] ?? '',
      tam10: map['tam10'] ?? '',
      tam11: map['tam11'] ?? '',
      tam12: map['tam12'] ?? '',
      tam13: map['tam13'] ?? '',
      tam14: map['tam14'] ?? '',
      tam15: map['tam15'] ?? '',
      e01: map['e01'] ?? '',
      e02: map['e02'] ?? '',
      e03: map['e03'] ?? '',
      e04: map['e04'] ?? '',
      e05: map['e05'] ?? '',
      e06: map['e06'] ?? '',
      e07: map['e07'] ?? '',
      e08: map['e08'] ?? '',
      e09: map['e09'] ?? '',
      e10: map['e10'] ?? '',
      e11: map['e11'] ?? '',
      e12: map['e12'] ?? '',
      e13: map['e13'] ?? '',
      e14: map['e14'] ?? '',
      e15: map['e15'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.image == image &&
        other.title == title &&
        other.price == price &&
        listEquals(other.tamanho, tamanho) &&
        other.tam01 == tam01 &&
        other.tam02 == tam02 &&
        other.tam03 == tam03 &&
        other.tam04 == tam04 &&
        other.tam05 == tam05 &&
        other.tam06 == tam06 &&
        other.tam07 == tam07 &&
        other.tam08 == tam08 &&
        other.tam09 == tam09 &&
        other.tam10 == tam10 &&
        other.tam11 == tam11 &&
        other.tam12 == tam12 &&
        other.tam13 == tam13 &&
        other.tam14 == tam14 &&
        other.tam15 == tam15 &&
        other.e01 == e01 &&
        other.e02 == e02 &&
        other.e03 == e03 &&
        other.e04 == e04 &&
        other.e05 == e05 &&
        other.e06 == e06 &&
        other.e07 == e07 &&
        other.e08 == e08 &&
        other.e09 == e09 &&
        other.e10 == e10 &&
        other.e11 == e11 &&
        other.e12 == e12 &&
        other.e13 == e13 &&
        other.e14 == e14 &&
        other.e15 == e15;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        image.hashCode ^
        title.hashCode ^
        price.hashCode ^
        tamanho.hashCode ^
        tam01.hashCode ^
        tam02.hashCode ^
        tam03.hashCode ^
        tam04.hashCode ^
        tam05.hashCode ^
        tam06.hashCode ^
        tam07.hashCode ^
        tam08.hashCode ^
        tam09.hashCode ^
        tam10.hashCode ^
        tam11.hashCode ^
        tam12.hashCode ^
        tam13.hashCode ^
        tam14.hashCode ^
        tam15.hashCode ^
        e01.hashCode ^
        e02.hashCode ^
        e03.hashCode ^
        e04.hashCode ^
        e05.hashCode ^
        e06.hashCode ^
        e07.hashCode ^
        e08.hashCode ^
        e09.hashCode ^
        e10.hashCode ^
        e11.hashCode ^
        e12.hashCode ^
        e13.hashCode ^
        e14.hashCode ^
        e15.hashCode;
  }

  @override
  String toString() {
    return 'Product(id: $id, image: $image, title: $title, price: $price, tamanho: $tamanho, estoque: $estoque, tam01: $tam01, tam02: $tam02, tam03: $tam03, tam04: $tam04, tam05: $tam05, tam06: $tam06, tam07: $tam07, tam08: $tam08, tam09: $tam09, tam10: $tam10, tam11: $tam11, tam12: $tam12, tam13: $tam13, tam14: $tam14, tam15: $tam15, e01: $e01, e02: $e02, e03: $e03, e04: $e04, e05: $e05, e06: $e06, e07: $e07, e08: $e08, e09: $e09, e10: $e10, e11: $e11, e12: $e12, e13: $e13, e14: $e14, e15: $e15)';
  }
}
