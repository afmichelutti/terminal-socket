class Ordem {
  Ordem({
    required this.id,
    required this.ordem,
    required this.pedido,
    required this.nomeCliente,
    required this.observacao,
    required this.dataOrdem,
    required this.prevEntrega,
    required this.idProduto,
    required this.nome,
    required this.quantidade,
    required this.dias,
    required this.celula,
    required this.tipo,
    required this.precoVenda,
    required this.emissao,
  });

  int id;
  int ordem;
  int pedido;
  String nomeCliente;
  String observacao;
  DateTime dataOrdem;
  DateTime prevEntrega;
  String idProduto;
  String nome;
  int quantidade;
  int dias;
  String celula;
  String tipo;
  double precoVenda;
  DateTime emissao;

  Ordem copyWith({
    int? id,
    int? ordem,
    int? pedido,
    String? nomeCliente,
    String? observacao,
    DateTime? dataOrdem,
    DateTime? prevEntrega,
    String? idProduto,
    String? nome,
    int? quantidade,
    int? dias,
    String? celula,
    String? tipo,
    double? precoVenda,
    DateTime? emissao,
  }) => Ordem(
    id: id ?? this.id,
    ordem: ordem ?? this.ordem,
    pedido: pedido ?? this.pedido,
    nomeCliente: nomeCliente ?? this.nomeCliente,
    observacao: observacao ?? this.observacao,
    dataOrdem: dataOrdem ?? this.dataOrdem,
    prevEntrega: prevEntrega ?? this.prevEntrega,
    idProduto: idProduto ?? this.idProduto,
    nome: nome ?? this.nome,
    quantidade: quantidade ?? this.quantidade,
    dias: dias ?? this.dias,
    celula: celula ?? this.celula,
    tipo: tipo ?? this.tipo,
    precoVenda: precoVenda ?? this.precoVenda,
    emissao: emissao ?? this.emissao,
  );

  factory Ordem.fromMap(Map<String, dynamic> json) => Ordem(
    // Conversão segura de números
    id: _parseIntSafely(json["id"]),
    ordem: _parseIntSafely(json["ordem"]),
    pedido: _parseIntSafely(json["pedido"]),

    // Strings com valores padrão
    nomeCliente: json["nome_cliente"] ?? "",
    observacao: json["observacao"] ?? "",

    // Datas com tratamento de erro
    dataOrdem: _parseDateSafely(json["data_ordem"]),
    prevEntrega: _parseDateSafely(json["prev_entrega"]),

    // Produto ID (pode ser int ou string)
    idProduto: json["id_produto"]?.toString() ?? "",
    nome: json["nome"] ?? "",

    // Valores numéricos
    quantidade: _parseIntSafely(json["quantidade"]),
    dias: _parseIntSafely(json["dias"]),

    celula: json["celula"] ?? "",
    tipo: json["tipo"] ?? "",
    precoVenda: _parseDoubleSafely(json["preco_venda"]),
    emissao: _parseDateSafely(json["emissao"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "ordem": ordem,
    "pedido": pedido,
    "nome_cliente": nomeCliente,
    "observacao": observacao,
    "data_ordem":
        "${dataOrdem.year.toString().padLeft(4, '0')}-${dataOrdem.month.toString().padLeft(2, '0')}-${dataOrdem.day.toString().padLeft(2, '0')}",
    "prev_entrega":
        "${prevEntrega.year.toString().padLeft(4, '0')}-${prevEntrega.month.toString().padLeft(2, '0')}-${prevEntrega.day.toString().padLeft(2, '0')}",
    "id_produto": idProduto,
    "nome": nome,
    "quantidade": quantidade,
    "dias": dias,
    "celula": celula,
    "tipo": tipo,
    "preco_venda": precoVenda,
    "emissao":
        "${emissao.year.toString().padLeft(4, '0')}-${emissao.month.toString().padLeft(2, '0')}-${emissao.day.toString().padLeft(2, '0')}",
  };

  // Métodos auxiliares para conversões seguras
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      if (value.isEmpty) return 0;
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDateSafely(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
