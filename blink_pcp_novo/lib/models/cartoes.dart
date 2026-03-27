import 'dart:convert';

import 'package:flutter/material.dart';

class CartaoModel {
  String titulo;
  Color color;
  String subtitulo;
  String valor;
  String total;
  String quantidade;

  CartaoModel({
    required this.titulo,
    required this.color,
    required this.subtitulo,
    required this.valor,
    required this.total,
    required this.quantidade,
  });

  CartaoModel copyWith({
    String? titulo,
    Color? color,
    String? subtitulo,
    String? valor,
    String? total,
    String? quantidade,
  }) {
    return CartaoModel(
      titulo: titulo ?? this.titulo,
      color: color ?? this.color,
      subtitulo: subtitulo ?? this.subtitulo,
      valor: valor ?? this.valor,
      total: total ?? this.total,
      quantidade: quantidade ?? this.quantidade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'color': color.value,
      'subtitulo': subtitulo,
      'valor': valor,
      'total': total,
      'quantidade': quantidade,
    };
  }

  factory CartaoModel.fromMap(Map<String, dynamic> map) {
    return CartaoModel(
      titulo: map['titulo'] ?? '',
      color: Color(map['color']),
      subtitulo: map['subtitulo'] ?? '',
      valor: map['valor'] ?? '',
      total: map['total'] ?? '',
      quantidade: map['quantidade'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CartaoModel.fromJson(String source) =>
      CartaoModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Card(titulo: $titulo, color: $color, subtitulo: $subtitulo, valor: $valor, total: $total)';
  }
}
