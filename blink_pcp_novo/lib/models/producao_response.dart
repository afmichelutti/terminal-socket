// To parse this JSON data, do
//
//     final producaoResponse = producaoResponseFromMap(jsonString);

import 'dart:convert';

class ProducaoResponse {
  ProducaoResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<Producao> data;

  ProducaoResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<Producao>? data,
  }) =>
      ProducaoResponse(
        apiStatus: apiStatus ?? this.apiStatus,
        apiMessage: apiMessage ?? this.apiMessage,
        data: data ?? this.data,
      );

  factory ProducaoResponse.fromJson(String str) =>
      ProducaoResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProducaoResponse.fromMap(Map<String, dynamic> json) =>
      ProducaoResponse(
        apiStatus: json["api_status"],
        apiMessage: json["api_message"],
        data: List<Producao>.from(json["data"].map((x) => Producao.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "api_status": apiStatus,
        "api_message": apiMessage,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class Producao {
  Producao({
    required this.mes,
    required this.quantidade,
  });

  String mes;
  int quantidade;

  Producao copyWith({
    String? mes,
    int? quantidade,
  }) =>
      Producao(
        mes: mes ?? this.mes,
        quantidade: quantidade ?? this.quantidade,
      );

  factory Producao.fromJson(String str) => Producao.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Producao.fromMap(Map<String, dynamic> json) => Producao(
        mes: json["mes"],
        quantidade: json["quantidade"],
      );

  Map<String, dynamic> toMap() => {
        "mes": mes,
        "quantidade": quantidade,
      };
}
