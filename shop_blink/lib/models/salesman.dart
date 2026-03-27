import 'dart:convert';

class Salesman {
  Salesman({
    required this.id,
    required this.nome,
  });

  int id;
  String nome;

  Salesman copyWith({
    int? id,
    String? nome,
  }) =>
      Salesman(
        id: id ?? this.id,
        nome: nome ?? this.nome,
      );

  factory Salesman.fromJson(String str) => Salesman.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Salesman.fromMap(Map<String, dynamic> json) => Salesman(
        id: json["id"],
        nome: json["nome"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "nome": nome,
      };
}
