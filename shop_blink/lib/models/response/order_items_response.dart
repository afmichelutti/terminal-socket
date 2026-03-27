// To parse this JSON data, do
//
//     final orderItemsResponse = orderItemsResponseFromMap(jsonString);

import 'dart:convert';

import 'package:shop_blink/models/order_item.dart';

class OrderItemsResponse {
  OrderItemsResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<OrderItem> data;

  OrderItemsResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<OrderItem>? data,
  }) => OrderItemsResponse(
    apiStatus: apiStatus ?? this.apiStatus,
    apiMessage: apiMessage ?? this.apiMessage,
    data: data ?? this.data,
  );

  factory OrderItemsResponse.fromJson(String str) =>
      OrderItemsResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderItemsResponse.fromMap(Map<String, dynamic> json) =>
      OrderItemsResponse(
        apiStatus: json["api_status"],
        apiMessage: json["api_message"],
        data: List<OrderItem>.from(
          json["data"].map((x) => OrderItem.fromMap(x)),
        ),
      );

  Map<String, dynamic> toMap() => {
    "api_status": apiStatus,
    "api_message": apiMessage,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
  };
}
