import 'dart:convert';

class OrderItem {
  OrderItem({
    required this.orderid,
    required this.nroitem,
    required this.nomeproduto,
    this.tamanho = '',
    required this.quantidade,
    required this.price,
  });

  int orderid;
  int nroitem;
  String nomeproduto;
  String? tamanho;
  int quantidade;
  double price;

  OrderItem copyWith({
    int? orderid,
    int? nroitem,
    String? nomeproduto,
    String? tamanho,
    int? quantidade,
    double? price,
  }) =>
      OrderItem(
        orderid: orderid ?? this.orderid,
        nroitem: nroitem ?? this.nroitem,
        nomeproduto: nomeproduto ?? this.nomeproduto,
        tamanho: tamanho ?? this.tamanho,
        quantidade: quantidade ?? this.quantidade,
        price: price ?? this.price,
      );

  factory OrderItem.fromJson(String str) => OrderItem.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
        orderid: json["orderid"],
        nroitem: json["nroitem"],
        nomeproduto: json["nomeproduto"],
        tamanho: json["tamanho"],
        quantidade: json["quantidade"],
        price: json["price"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "orderid": orderid,
        "nroitem": nroitem,
        "nomeproduto": nomeproduto,
        "tamanho": tamanho,
        "quantidade": quantidade,
        "price": price,
      };
}
