// To parse this JSON data, do
//
//     final ordensResponse = ordensResponseFromMap(jsonString);

import 'dart:convert';

import 'package:painel_producao_blink/models/ordem.dart';

OrdensResponse ordensResponseFromMap(String str) =>
    OrdensResponse.fromMap(json.decode(str));

String ordensResponseToMap(OrdensResponse data) => json.encode(data.toMap());

class OrdensResponse {
  OrdensResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.ordens,
  });

  int apiStatus;
  String apiMessage;
  List<Ordem> ordens;

  OrdensResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<Ordem>? ordens,
  }) => OrdensResponse(
    apiStatus: apiStatus ?? this.apiStatus,
    apiMessage: apiMessage ?? this.apiMessage,
    ordens: ordens ?? this.ordens,
  );

  factory OrdensResponse.fromMap(Map<String, dynamic> json) => OrdensResponse(
    apiStatus: json["api_status"],
    apiMessage: json["api_message"],
    ordens: List<Ordem>.from(json["data"].map((x) => Ordem.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "api_status": apiStatus,
    "api_message": apiMessage,
    "data": List<dynamic>.from(ordens.map((x) => x.toMap())),
  };
}
