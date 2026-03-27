// To parse this JSON data, do
//
//     final authResponse = authResponseFromMap(jsonString);

import 'dart:convert';

import 'package:shop_blink/models/user.dart';

class AuthResponse {
  AuthResponse({required this.user, required this.token});

  User user;
  Token token;

  AuthResponse copyWith({User? user, Token? token}) =>
      AuthResponse(user: user ?? this.user, token: token ?? this.token);

  factory AuthResponse.fromJson(String str) =>
      AuthResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AuthResponse.fromMap(Map<String, dynamic> json) => AuthResponse(
    user: User.fromMap(json["user"]),
    token: Token.fromMap(json["token"]),
  );

  Map<String, dynamic> toMap() => {
    "user": user.toMap(),
    "token": token.toMap(),
  };
}

class Token {
  Token({required this.type, required this.token, required this.expiresAt});

  String type;
  String token;
  DateTime expiresAt;

  Token copyWith({String? type, String? token, DateTime? expiresAt}) => Token(
    type: type ?? this.type,
    token: token ?? this.token,
    expiresAt: expiresAt ?? this.expiresAt,
  );

  factory Token.fromJson(String str) => Token.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Token.fromMap(Map<String, dynamic> json) => Token(
    type: json["type"],
    token: json["token"],
    expiresAt: DateTime.parse(json["expires_at"]),
  );

  Map<String, dynamic> toMap() => {
    "type": type,
    "token": token,
    "expires_at": expiresAt.toIso8601String(),
  };
}
