import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movimentacao.dart';

/// Controlador responsável pelo CRUD de movimentações, cálculos financeiros
/// e persistência local utilizando SharedPreferences (mesmo padrão visto em aula).
class MovimentacaoController {
  static const String _chaveStorage = 'project_x_movimentacoes_simples_v1';

  /// Lista de movimentações carregadas em memória.
  static List<Movimentacao> lista = [];

  /// Carrega as movimentações salvas no SharedPreferences.
  /// Caso seja a primeira vez abrindo o app, carrega dados de exemplo.
  static Future<void> carregar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? dados = prefs.getStringList(_chaveStorage);

    if (dados != null) {
      lista = dados
          .map((item) => Movimentacao.fromJson(jsonDecode(item)))
          .toList();
      _ordenarPorDataMaisRecente();
    } else {
      await restaurarDadosExemplo();
    }
  }

  /// Salva a lista atual de movimentações no SharedPreferences em formato JSON.
  static Future<void> salvar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _ordenarPorDataMaisRecente();
    final List<String> dados =
        lista.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_chaveStorage, dados);
  }

  /// Inclui uma nova movimentação e persiste no armazenamento local.
  static Future<void> incluir(Movimentacao nova) async {
    lista.add(nova);
    await salvar();
  }

  /// Edita uma movimentação existente buscando pelo seu id.
  static Future<void> editar(Movimentacao atualizada) async {
    final int index = lista.indexWhere((m) => m.id == atualizada.id);
    if (index != -1) {
      lista[index] = atualizada;
      await salvar();
    }
  }

  /// Exclui uma movimentação pelo seu id.
  static Future<void> excluir(String id) async {
    lista.removeWhere((m) => m.id == id);
    await salvar();
  }

  /// Soma todas as receitas cadastradas.
  static double calcularTotalReceitas() {
    double total = 0;
    for (final m in lista) {
      if (m.ehReceita) total += m.valor;
    }
    return total;
  }

  /// Soma todas as despesas cadastradas.
  static double calcularTotalDespesas() {
    double total = 0;
    for (final m in lista) {
      if (m.ehDespesa) total += m.valor;
    }
    return total;
  }

  /// Calcula o saldo disponível atual (Total de Receitas - Total de Despesas).
  static double calcularSaldoAtual() {
    return calcularTotalReceitas() - calcularTotalDespesas();
  }

  /// Filtra as movimentações combinando busca textual e Checkboxes de tipo.
  static List<Movimentacao> filtrar({
    String termoBusca = '',
    bool mostrarReceitas = true,
    bool mostrarDespesas = true,
  }) {
    final String busca = termoBusca.trim().toLowerCase();

    return lista.where((m) {
      if (m.ehReceita && !mostrarReceitas) return false;
      if (m.ehDespesa && !mostrarDespesas) return false;

      if (busca.isNotEmpty) {
        final bool bateDescricao = m.descricao.toLowerCase().contains(busca);
        final bool bateCategoria = m.categoria.toLowerCase().contains(busca);
        final bool bateObs = m.observacao.toLowerCase().contains(busca);
        if (!bateDescricao && !bateCategoria && !bateObs) return false;
      }

      return true;
    }).toList();
  }

  /// Popula o aplicativo com lançamentos iniciais de demonstração.
  static Future<void> restaurarDadosExemplo() async {
    final DateTime hoje = DateTime.now();
    lista = [
      Movimentacao(
        id: 'mov_1',
        descricao: 'Salário Mensal',
        valor: 4500.00,
        data: DateTime(hoje.year, hoje.month, 5),
        tipo: 'receita',
        categoria: 'Salário',
        observacao: 'Pagamento mensal na conta corrente',
      ),
      Movimentacao(
        id: 'mov_2',
        descricao: 'Aluguel e Condomínio',
        valor: 1350.00,
        data: DateTime(hoje.year, hoje.month, 8),
        tipo: 'despesa',
        categoria: 'Moradia',
        observacao: 'Referente ao mês atual',
      ),
      Movimentacao(
        id: 'mov_3',
        descricao: 'Compras de Supermercado',
        valor: 680.50,
        data: DateTime(hoje.year, hoje.month, 10),
        tipo: 'despesa',
        categoria: 'Alimentação',
        observacao: 'Compras da quinzena',
      ),
      Movimentacao(
        id: 'mov_4',
        descricao: 'Projeto Web Freelance',
        valor: 950.00,
        data: DateTime(hoje.year, hoje.month, 12),
        tipo: 'receita',
        categoria: 'Freelance',
        observacao: 'Entrega de landing page',
      ),
      Movimentacao(
        id: 'mov_5',
        descricao: 'Combustível e Transporte',
        valor: 260.00,
        data: DateTime(hoje.year, hoje.month, 14),
        tipo: 'despesa',
        categoria: 'Transporte',
      ),
      Movimentacao(
        id: 'mov_6',
        descricao: 'Cinema e Jantar no Fim de Semana',
        valor: 145.00,
        data: DateTime(hoje.year, hoje.month, 16),
        tipo: 'despesa',
        categoria: 'Lazer',
      ),
    ];
    await salvar();
  }

  static void _ordenarPorDataMaisRecente() {
    lista.sort((a, b) => b.data.compareTo(a.data));
  }
}
