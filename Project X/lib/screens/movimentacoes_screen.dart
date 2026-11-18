import 'package:flutter/material.dart';
import '../controllers/movimentacao_controller.dart';
import '../models/movimentacao.dart';
import '../widgets/item_movimentacao.dart';

/// Tela de Extrato e Filtragem de Movimentações (StatefulWidget).
/// Demonstra o uso de DefaultTabController + TabBar + TabBarView,
/// TextEditingController (com dispose), Checkbox e ListView.builder.
class MovimentacoesScreen extends StatefulWidget {
  final Future<void> Function(Movimentacao mov) aoEditarMovimentacao;
  final Future<void> Function(Movimentacao mov) aoExcluirMovimentacao;

  const MovimentacoesScreen({
    super.key,
    required this.aoEditarMovimentacao,
    required this.aoExcluirMovimentacao,
  });

  @override
  State<MovimentacoesScreen> createState() => _MovimentacoesScreenState();
}

class _MovimentacoesScreenState extends State<MovimentacoesScreen> {
  final TextEditingController _buscaCtrl = TextEditingController();
  bool _incluirReceitas = true;
  bool _incluirDespesas = true;

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  /// Constrói a lista usando ListView.builder para a aba selecionada.
  Widget _construirLista({
    required bool mostrarReceitas,
    required bool mostrarDespesas,
  }) {
    final List<Movimentacao> filtradas = MovimentacaoController.filtrar(
      termoBusca: _buscaCtrl.text,
      mostrarReceitas: mostrarReceitas,
      mostrarDespesas: mostrarDespesas,
    );

    if (filtradas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma movimentação encontrada para este filtro.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: filtradas.length,
      itemBuilder: (BuildContext context, int index) {
        final Movimentacao mov = filtradas[index];
        return ItemMovimentacao(
          movimentacao: mov,
          aoEditar: () => widget.aoEditarMovimentacao(mov),
          aoExcluir: () => widget.aoExcluirMovimentacao(mov),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Barra de Abas (TabBar vista em sala)
          Container(
            color: Colors.white,
            child: const TabBar(
              tabs: [
                Tab(text: 'Todas'),
                Tab(text: 'Receitas'),
                Tab(text: 'Despesas'),
              ],
            ),
          ),

          // Barra de Busca (TextEditingController) + Filtros (Checkbox)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                TextField(
                  controller: _buscaCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por descrição ou categoria...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _buscaCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _buscaCtrl.clear();
                              });
                            },
                          )
                        : null,
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _incluirReceitas,
                      activeColor: const Color(0xFF16A34A),
                      onChanged: (bool? valor) {
                        setState(() {
                          _incluirReceitas = valor ?? true;
                        });
                      },
                    ),
                    const Text('Receitas'),
                    const SizedBox(width: 16),
                    Checkbox(
                      value: _incluirDespesas,
                      activeColor: const Color(0xFFE11D48),
                      onChanged: (bool? valor) {
                        setState(() {
                          _incluirDespesas = valor ?? true;
                        });
                      },
                    ),
                    const Text('Despesas'),
                  ],
                ),
              ],
            ),
          ),

          // Conteúdo das 3 abas (TabBarView)
          Expanded(
            child: TabBarView(
              children: [
                _construirLista(
                  mostrarReceitas: _incluirReceitas,
                  mostrarDespesas: _incluirDespesas,
                ),
                _construirLista(
                  mostrarReceitas: true,
                  mostrarDespesas: false,
                ),
                _construirLista(
                  mostrarReceitas: false,
                  mostrarDespesas: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
