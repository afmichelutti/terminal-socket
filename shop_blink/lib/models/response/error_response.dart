// To parse this JSON data, do
//
//     final errorResponse = errorResponseFromMap(jsonString);

import 'dart:convert';

class ErrorResponse {
  ErrorResponse({
    required this.errors,
  });

  List<Error> errors;

  ErrorResponse copyWith({
    List<Error>? errors,
  }) =>
      ErrorResponse(
        errors: errors ?? this.errors,
      );

  factory ErrorResponse.fromJson(String str) =>
      ErrorResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ErrorResponse.fromMap(Map<String, dynamic> json) => ErrorResponse(
        errors: List<Error>.from(json["errors"].map((x) => Error.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "errors": List<dynamic>.from(errors.map((x) => x.toMap())),
      };
}

class Error {
  Error({
    required this.rule,
    required this.field,
    required this.message,
  });

  String rule;
  String field;
  String message;

  Error copyWith({
    String? rule,
    String? field,
    String? message,
  }) =>
      Error(
        rule: rule ?? this.rule,
        field: field ?? this.field,
        message: message ?? this.message,
      );

  factory Error.fromJson(String str) => Error.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Error.fromMap(Map<String, dynamic> json) => Error(
        rule: json["rule"],
        field: json["field"],
        message: json["message"],
      );

  Map<String, dynamic> toMap() => {
        "rule": rule,
        "field": field,
        "message": message,
      };
}
