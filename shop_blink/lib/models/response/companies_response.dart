// To parse this JSON data, do
//
//     final companiesReponse = companiesReponseFromMap(jsonString);

import 'dart:convert';

import 'package:shop_blink/models/company.dart';

class CompaniesReponse {
  CompaniesReponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<Company> data;

  CompaniesReponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<Company>? data,
  }) => CompaniesReponse(
    apiStatus: apiStatus ?? this.apiStatus,
    apiMessage: apiMessage ?? this.apiMessage,
    data: data ?? this.data,
  );

  factory CompaniesReponse.fromJson(String str) =>
      CompaniesReponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CompaniesReponse.fromMap(Map<String, dynamic> json) =>
      CompaniesReponse(
        apiStatus: json["api_status"],
        apiMessage: json["api_message"],
        data: List<Company>.from(json["data"].map((x) => Company.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
    "api_status": apiStatus,
    "api_message": apiMessage,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
  };
}
