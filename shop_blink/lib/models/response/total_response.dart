// To parse this JSON data, do
//
//     final totalResponse = totalResponseFromMap(jsonString);

import 'dart:convert';

class TotalResponse {
  TotalResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<Datum> data;

  TotalResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<Datum>? data,
  }) =>
      TotalResponse(
        apiStatus: apiStatus ?? this.apiStatus,
        apiMessage: apiMessage ?? this.apiMessage,
        data: data ?? this.data,
      );

  factory TotalResponse.fromJson(String str) =>
      TotalResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TotalResponse.fromMap(Map<String, dynamic> json) => TotalResponse(
        apiStatus: json["api_status"],
        apiMessage: json["api_message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "api_status": apiStatus,
        "api_message": apiMessage,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class Datum {
  Datum({
    required this.amount,
    required this.quantidade,
  });

  double amount;
  int quantidade;

  Datum copyWith({
    double? amount,
    int? quantidade,
  }) =>
      Datum(
        amount: amount ?? this.amount,
        quantidade: quantidade ?? this.quantidade,
      );

  factory Datum.fromJson(String str) => Datum.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
        amount: json["amount"] != null ? json["amount"].toDouble() : 0.0,
        quantidade: json["quantidade"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "amount": amount,
        "quantidade": quantidade,
      };
}
