// To parse this JSON data, do
//
//     final userAuthResponse = userAuthResponseFromMap(jsonString);

import 'dart:convert';

import 'package:shop_blink/models/user.dart';

class UserAuthResponse {
  UserAuthResponse({required this.user});

  User user;

  UserAuthResponse copyWith({User? user}) =>
      UserAuthResponse(user: user ?? this.user);

  factory UserAuthResponse.fromJson(String str) =>
      UserAuthResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserAuthResponse.fromMap(Map<String, dynamic> json) =>
      UserAuthResponse(user: User.fromMap(json["user"]));

  Map<String, dynamic> toMap() => {"user": user.toMap()};
}
