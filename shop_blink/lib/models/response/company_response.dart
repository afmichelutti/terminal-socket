// To parse this JSON data, do
//
//     final companyResponse = companyResponseFromMap(jsonString);

import 'dart:convert';

class CompanyResponse {
  CompanyResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<int> data;

  CompanyResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<int>? data,
  }) =>
      CompanyResponse(
        apiStatus: apiStatus ?? this.apiStatus,
        apiMessage: apiMessage ?? this.apiMessage,
        data: data ?? this.data,
      );

  factory CompanyResponse.fromJson(String str) =>
      CompanyResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CompanyResponse.fromMap(Map<String, dynamic> json) => CompanyResponse(
        apiStatus: json["api_status"],
        apiMessage: json["api_message"],
        data: List<int>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "api_status": apiStatus,
        "api_message": apiMessage,
        "data": List<dynamic>.from(data.map((x) => x)),
      };
}
