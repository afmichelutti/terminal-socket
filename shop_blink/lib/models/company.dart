import 'dart:convert';

class Company {
  Company({
    required this.id,
    required this.name,
    required this.fantasy,
    required this.cnpj,
    required this.tokenSocket,
    this.selected = false,
  });

  int id;
  String name;
  String fantasy;
  String cnpj;
  String tokenSocket;
  bool selected;

  Company copyWith({
    int? id,
    String? name,
    String? fantasy,
    String? cnpj,
    String? tokenSocket,
  }) =>
      Company(
        id: id ?? this.id,
        name: name ?? this.name,
        fantasy: fantasy ?? this.fantasy,
        cnpj: cnpj ?? this.cnpj,
        tokenSocket: tokenSocket ?? this.tokenSocket,
      );

  factory Company.fromJson(String str) => Company.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Company.fromMap(Map<String, dynamic> json) => Company(
        id: json["id"],
        name: json["name"],
        fantasy: json["fantasy"],
        cnpj: json["cnpj"],
        tokenSocket: json["token_socket"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "fantasy": fantasy,
        "cnpj": cnpj,
        "token_socket": tokenSocket,
      };
}
