import 'dart:convert';

class Token {
  Token({
    required this.type,
    required this.token,
    required this.expiresAt,
  });

  String type;
  String token;
  DateTime expiresAt;

  Token copyWith({
    String? type,
    String? token,
    DateTime? expiresAt,
  }) =>
      Token(
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
