// To parse this JSON data, do
//
//     final orderResponse = orderResponseFromMap(jsonString);

import 'dart:convert';

class OrderResponse {
  OrderResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<OrderResp> data;

  OrderResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<OrderResp>? data,
  }) =>
      OrderResponse(
        apiStatus: apiStatus ?? this.apiStatus,
        apiMessage: apiMessage ?? this.apiMessage,
        data: data ?? this.data,
      );

  factory OrderResponse.fromJson(String str) =>
      OrderResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderResponse.fromMap(Map<String, dynamic> json) => OrderResponse(
        apiStatus: json["api_status"],
        apiMessage: json["api_message"],
        data:
            List<OrderResp>.from(json["data"].map((x) => OrderResp.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "api_status": apiStatus,
        "api_message": apiMessage,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class OrderResp {
  OrderResp({
    required this.id,
    required this.idCod,
  });

  int id;
  int idCod;

  OrderResp copyWith({
    int? id,
    int? idCod,
  }) =>
      OrderResp(
        id: id ?? this.id,
        idCod: idCod ?? this.idCod,
      );

  factory OrderResp.fromJson(String str) => OrderResp.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderResp.fromMap(Map<String, dynamic> json) => OrderResp(
        id: json["id"],
        idCod: json["id_cod"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "id_cod": idCod,
      };
}
