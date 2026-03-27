// To parse this JSON data, do
//
//     final statusResponse = statusResponseFromMap(jsonString);

import 'dart:convert';

class StatusResponse {
  StatusResponse({
    required this.apiStatus,
    required this.apiMessage,
    required this.data,
  });

  int apiStatus;
  String apiMessage;
  List<Server> data;

  StatusResponse copyWith({
    int? apiStatus,
    String? apiMessage,
    List<Server>? data,
  }) =>
      StatusResponse(
        apiStatus: apiStatus ?? this.apiStatus,
        apiMessage: apiMessage ?? this.apiMessage,
        data: data ?? this.data,
      );

  factory StatusResponse.fromJson(String str) =>
      StatusResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StatusResponse.fromMap(Map<String, dynamic> json) => StatusResponse(
        apiStatus: json["api_status"],
        apiMessage: json["api_message"],
        data: List<Server>.from(json["data"].map((x) => Server.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "api_status": apiStatus,
        "api_message": apiMessage,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class Server {
  Server({
    required this.system,
    required this.cpu,
    required this.ip,
    required this.name,
    required this.domain,
    required this.username,
    required this.memory,
    required this.database,
  });

  String system;
  String cpu;
  String ip;
  String name;
  String domain;
  String username;
  String memory;
  Database database;

  Server copyWith({
    String? system,
    String? cpu,
    String? ip,
    String? name,
    String? domain,
    String? username,
    String? memory,
    Database? database,
  }) =>
      Server(
        system: system ?? this.system,
        cpu: cpu ?? this.cpu,
        ip: ip ?? this.ip,
        name: name ?? this.name,
        domain: domain ?? this.domain,
        username: username ?? this.username,
        memory: memory ?? this.memory,
        database: database ?? this.database,
      );

  factory Server.fromJson(String str) => Server.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Server.fromMap(Map<String, dynamic> json) => Server(
        system: json["system"],
        cpu: json["cpu"],
        ip: json["ip"],
        name: json["name"],
        domain: json["domain"],
        username: json["username"],
        memory: json["memory"],
        database: Database.fromMap(json["database"]),
      );

  Map<String, dynamic> toMap() => {
        "system": system,
        "cpu": cpu,
        "ip": ip,
        "name": name,
        "domain": domain,
        "username": username,
        "memory": memory,
        "database": database.toMap(),
      };
}

class Database {
  Database({
    required this.server,
    required this.database,
    required this.user,
    required this.port,
  });

  String server;
  String database;
  String user;
  String port;

  Database copyWith({
    String? server,
    String? database,
    String? user,
    String? port,
  }) =>
      Database(
        server: server ?? this.server,
        database: database ?? this.database,
        user: user ?? this.user,
        port: port ?? this.port,
      );

  factory Database.fromJson(String str) => Database.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Database.fromMap(Map<String, dynamic> json) => Database(
        server: json["server"],
        database: json["database"],
        user: json["user"],
        port: json["port"],
      );

  Map<String, dynamic> toMap() => {
        "server": server,
        "database": database,
        "user": user,
        "port": port,
      };
}
