// To parse this JSON data, do
//
//     final ordersResponse = ordersResponseFromMap(jsonString);

import 'dart:convert';

import 'package:shop_blink/models/order.dart';

class OrdersResponse {
  OrdersResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<Order> data;

  OrdersResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<Order>? data,
  }) => OrdersResponse(
    apiStatus: apiStatus ?? this.apiStatus,
    apiMessage: apiMessage ?? this.apiMessage,
    data: data ?? this.data,
  );

  factory OrdersResponse.fromJson(String str) =>
      OrdersResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrdersResponse.fromMap(Map<String, dynamic> json) => OrdersResponse(
    apiStatus: json["api_status"],
    apiMessage: json["api_message"],
    data: List<Order>.from(json["data"].map((x) => Order.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "api_status": apiStatus,
    "api_message": apiMessage,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
  };
}
