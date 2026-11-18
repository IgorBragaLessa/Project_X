/// Modelo de dados que representa uma Movimentação Financeira (Receita ou Despesa).
class Movimentacao {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String tipo; // 'receita' ou 'despesa'
  final String categoria;
  final String observacao;

  const Movimentacao({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.tipo,
    required this.categoria,
    this.observacao = '',
  });

  /// Retorna true se a movimentação for uma entrada (receita).
  bool get ehReceita => tipo == 'receita';

  /// Retorna true se a movimentação for uma saída (despesa).
  bool get ehDespesa => tipo == 'despesa';

  /// Converte o objeto Movimentacao para um Map (para salvar em JSON no SharedPreferences).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
      'tipo': tipo,
      'categoria': categoria,
      'observacao': observacao,
    };
  }

  /// Reconstrói um objeto Movimentacao a partir de um Map decodificado do JSON.
  factory Movimentacao.fromJson(Map<String, dynamic> json) {
    return Movimentacao(
      id: json['id'] ?? '',
      descricao: json['descricao'] ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      data: DateTime.tryParse(json['data'] ?? '') ?? DateTime.now(),
      tipo: json['tipo'] ?? 'despesa',
      categoria: json['categoria'] ?? 'Outros',
      observacao: json['observacao'] ?? '',
    );
  }
}
