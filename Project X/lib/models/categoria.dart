import 'package:flutter/material.dart';

/// Modelo que representa uma Categoria de Receita ou Despesa com seu ícone e cor.
class Categoria {
  final String nome;
  final String tipo; // 'receita' ou 'despesa'
  final IconData icone;
  final Color cor;

  const Categoria({
    required this.nome,
    required this.tipo,
    required this.icone,
    required this.cor,
  });

  /// Lista fixa de categorias padrão do aplicativo.
  static const List<Categoria> listaPadrao = [
    // Categorias de Despesa
    Categoria(
      nome: 'Alimentação',
      tipo: 'despesa',
      icone: Icons.restaurant_outlined,
      cor: Color(0xFFF59E0B),
    ),
    Categoria(
      nome: 'Transporte',
      tipo: 'despesa',
      icone: Icons.directions_car_outlined,
      cor: Color(0xFF0EA5E9),
    ),
    Categoria(
      nome: 'Moradia',
      tipo: 'despesa',
      icone: Icons.home_outlined,
      cor: Color(0xFF6366F1),
    ),
    Categoria(
      nome: 'Lazer',
      tipo: 'despesa',
      icone: Icons.sports_esports_outlined,
      cor: Color(0xFF8B5CF6),
    ),
    Categoria(
      nome: 'Saúde',
      tipo: 'despesa',
      icone: Icons.favorite_border,
      cor: Color(0xFFE11D48),
    ),
    Categoria(
      nome: 'Educação',
      tipo: 'despesa',
      icone: Icons.school_outlined,
      cor: Color(0xFF14B8A6),
    ),
    // Categorias de Receita
    Categoria(
      nome: 'Salário',
      tipo: 'receita',
      icone: Icons.payments_outlined,
      cor: Color(0xFF16A34A),
    ),
    Categoria(
      nome: 'Freelance',
      tipo: 'receita',
      icone: Icons.work_outline,
      cor: Color(0xFF84CC16),
    ),
    Categoria(
      nome: 'Investimentos',
      tipo: 'receita',
      icone: Icons.trending_up,
      cor: Color(0xFF10B981),
    ),
  ];

  /// Filtra as categorias pelo tipo ('receita' ou 'despesa').
  static List<Categoria> porTipo(String tipo) {
    return listaPadrao.where((c) => c.tipo == tipo).toList();
  }

  /// Busca os dados visuais (ícone e cor) de uma categoria pelo nome.
  static Categoria buscarPorNome(String nome) {
    for (final cat in listaPadrao) {
      if (cat.nome.toLowerCase() == nome.toLowerCase()) {
        return cat;
      }
    }
    return const Categoria(
      nome: 'Outros',
      tipo: 'despesa',
      icone: Icons.category_outlined,
      cor: Color(0xFF64748B),
    );
  }
}
