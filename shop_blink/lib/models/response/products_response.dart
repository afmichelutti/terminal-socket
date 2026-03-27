// To parse this JSON data, do
//
//     final restaurantesReponse = restaurantesReponseFromMap(jsonString);

import 'dart:convert';

import 'package:shop_blink/models/product.dart';

class ProductsReponse {
  ProductsReponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<Product> data;

  ProductsReponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<Product>? data,
  }) => ProductsReponse(
    apiStatus: apiStatus ?? this.apiStatus,
    apiMessage: apiMessage ?? this.apiMessage,
    data: data ?? this.data,
  );

  factory ProductsReponse.fromJson(String str) =>
      ProductsReponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductsReponse.fromMap(Map<String, dynamic> json) => ProductsReponse(
    apiStatus: json["api_status"],
    apiMessage: json["api_message"],
    data: List<Product>.from(json["data"].map((x) => Product.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "api_status": apiStatus,
    "api_message": apiMessage,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
  };
}
