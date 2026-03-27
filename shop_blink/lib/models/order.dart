import 'dart:convert';

import 'package:shop_blink/models/order_item.dart';

class Order {
  Order({
    required this.id,
    required this.codigo,
    required this.dataCom,
    required this.salesman,
    required this.amount,
    required this.quantidade,
    required this.items,
  });

  int id;
  int codigo;
  DateTime dataCom;
  String salesman;
  double amount;
  int quantidade;
  List<OrderItem> items = [];

  Order copyWith({
    int? id,
    int? codigo,
    DateTime? dataCom,
    String? salesman,
    double? amount,
    int? quantidade,
    List<OrderItem>? items,
  }) => Order(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    dataCom: dataCom ?? this.dataCom,
    salesman: salesman ?? this.salesman,
    amount: amount ?? this.amount,
    quantidade: quantidade ?? this.quantidade,
    items: items ?? this.items,
  );

  factory Order.fromJson(String str) => Order.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Order.fromMap(Map<String, dynamic> json) => Order(
    id: json["id"],
    codigo: json["codigo"],
    dataCom: DateTime.parse(json["data_com"]),
    salesman: json["salesman"],
    amount: json["amount"].toDouble(),
    quantidade: json["quantidade"],
    items:
        json["items"] != null
            ? List<OrderItem>.from(
              json["items"].map((x) => OrderItem.fromMap(x)),
            )
            : [],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "codigo": codigo,
    "data_com": dataCom.toIso8601String(),
    "salesman": salesman,
    "amount": amount,
    "quantidade": quantidade,
    "items": List<dynamic>.from(items.map((x) => x.toMap())),
  };
}
