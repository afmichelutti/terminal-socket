// To parse this JSON data, do
//
//     final userAuthResponse = userAuthResponseFromMap(jsonString);

import 'dart:convert';

import 'package:shop_blink/models/salesman.dart';

class SalesmanResponse {
  SalesmanResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<Salesman> data;

  SalesmanResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<Salesman>? data,
  }) => SalesmanResponse(
    apiStatus: apiStatus ?? this.apiStatus,
    apiMessage: apiMessage ?? this.apiMessage,
    data: data ?? this.data,
  );

  factory SalesmanResponse.fromJson(String str) =>
      SalesmanResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SalesmanResponse.fromMap(Map<String, dynamic> json) =>
      SalesmanResponse(
        apiStatus: json["api_status"],
        apiMessage: json["api_message"],
        data: List<Salesman>.from(json["data"].map((x) => Salesman.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
    "api_status": apiStatus,
    "api_message": apiMessage,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
  };
}
