import 'dart:convert';

class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.loja,
    required this.tokenSocket,
    required this.roleId,
  });

  String id;
  String username;
  String email;
  int loja;
  String tokenSocket;
  int roleId;

  User copyWith({
    String? id,
    String? username,
    String? email,
    int? loja,
    String? tokenSocket,
    int? roleId,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        loja: loja ?? this.loja,
        tokenSocket: tokenSocket ?? this.tokenSocket,
        roleId: roleId ?? this.roleId,
      );

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        loja: json["loja"],
        tokenSocket: json["token_socket"],
        roleId: json["role_id"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "username": username,
        "email": email,
        "loja": loja,
        "token_socket": tokenSocket,
        "role_id": roleId,
      };

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, loja: $loja, tokenSocket: $tokenSocket, roleId: $roleId)';
  }
}
