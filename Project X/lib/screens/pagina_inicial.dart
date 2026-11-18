import 'package:flutter/material.dart';
import '../controllers/movimentacao_controller.dart';
import '../models/movimentacao.dart';
import 'dashboard_screen.dart';
import 'formulario_movimentacao.dart';
import 'movimentacoes_screen.dart';

/// Shell principal do aplicativo (StatefulWidget).
/// Utiliza BottomNavigationBar para alternar entre as telas,
/// SimpleDialog no botão flutuante (+), AlertDialog e Tooltip na AppBar.
class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  int _paginaAtual = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    await MovimentacaoController.carregar();
    if (mounted) {
      setState(() {});
    }
  }

  /// Abre um SimpleDialog (visto em sala) para o usuário escolher entre
  /// cadastrar uma Nova Despesa ou uma Nova Receita.
  Future<void> _abrirSimpleDialogNovoLancamento() async {
    final String? tipoEscolhido = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return SimpleDialog(
          title: const Text('Novo Lançamento'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'despesa'),
              child: const Row(
                children: [
                  Icon(Icons.remove_circle_outline, color: Color(0xFFE11D48)),
                  SizedBox(width: 10),
                  Text('Nova Despesa (Saída)'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'receita'),
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Color(0xFF16A34A)),
                  SizedBox(width: 10),
                  Text('Nova Receita (Entrada)'),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (tipoEscolhido != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormularioMovimentacao(
            tipoInicial: tipoEscolhido,
          ),
        ),
      );
      setState(() {});
    }
  }

  /// Abre a tela de formulário para editar uma movimentação existente.
  Future<void> _editarMovimentacao(Movimentacao mov) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioMovimentacao(
          movimentacaoExistente: mov,
        ),
      ),
    );
    setState(() {});
  }

  /// Exclui uma movimentação e exibe um SnackBar de confirmação.
  Future<void> _excluirMovimentacao(Movimentacao mov) async {
    await MovimentacaoController.excluir(mov.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${mov.descricao}" foi excluída.'),
      ),
    );
  }

  /// Abre um AlertDialog para confirmar a restauração dos dados de exemplo.
  Future<void> _confirmarRestaurarExemplos() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Restaurar Dados de Exemplo'),
          content: const Text(
            'Deseja recarregar as movimentações iniciais de demonstração?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restaurar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await MovimentacaoController.restaurarDadosExemplo();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados de demonstração restaurados!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      DashboardScreen(
        aoIrParaExtrato: () {
          setState(() {
            _paginaAtual = 1;
          });
        },
        aoEditarMovimentacao: _editarMovimentacao,
        aoExcluirMovimentacao: _excluirMovimentacao,
      ),
      MovimentacoesScreen(
        aoEditarMovimentacao: _editarMovimentacao,
        aoExcluirMovimentacao: _excluirMovimentacao,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF16A34A)),
            SizedBox(width: 10),
            Text('Project X — Finanças'),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Restaurar dados de exemplo',
            child: IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _confirmarRestaurarExemplos,
            ),
          ),
        ],
      ),
      body: paginas.elementAt(_paginaAtual),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirSimpleDialogNovoLancamento,
        tooltip: 'Adicionar Receita ou Despesa',
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        selectedItemColor: const Color(0xFF16A34A),
        onTap: (int indice) {
          setState(() {
            _paginaAtual = indice;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Resumo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Extrato',
          ),
        ],
      ),
    );
  }
}
