import 'package:flutter/material.dart';
import '../controllers/movimentacao_controller.dart';
import '../models/movimentacao.dart';
import '../utils/formatador.dart';
import '../widgets/item_movimentacao.dart';

/// StatelessWidget reutilizável para exibir os cartões de indicadores financeiros
/// (Saldo Disponível, Receitas e Despesas).
class CardResumo extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;

  const CardResumo({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: cor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela de Visão Geral / Dashboard (StatefulWidget).
/// Exibe os cartões de resumo, barra de proporção de gastos (LinearProgressIndicator)
/// e a lista das últimas movimentações registradas.
class DashboardScreen extends StatefulWidget {
  final VoidCallback aoIrParaExtrato;
  final Future<void> Function(Movimentacao mov) aoEditarMovimentacao;
  final Future<void> Function(Movimentacao mov) aoExcluirMovimentacao;

  const DashboardScreen({
    super.key,
    required this.aoIrParaExtrato,
    required this.aoEditarMovimentacao,
    required this.aoExcluirMovimentacao,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final double receitas = MovimentacaoController.calcularTotalReceitas();
    final double despesas = MovimentacaoController.calcularTotalDespesas();
    final double saldo = MovimentacaoController.calcularSaldoAtual();

    // Calcula o percentual das receitas que foi comprometido com despesas
    final double proporcaoGasto =
        receitas > 0 ? (despesas / receitas).clamp(0.0, 1.0) : 0.0;
    final int percentualGasto =
        receitas > 0 ? ((despesas / receitas) * 100).round() : 0;

    final List<Movimentacao> ultimas =
        MovimentacaoController.lista.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // Cartão Principal de Saldo
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF1D3B34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo Disponível',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13.5),
              ),
              const SizedBox(height: 6),
              Text(
                Formatador.moeda(saldo),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comprometimento da renda: $percentualGasto%',
                    style: const TextStyle(
                      color: Color(0xFFBEF264),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${MovimentacaoController.lista.length} lançamentos',
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: proporcaoGasto,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  color: proporcaoGasto > 0.85
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF84CC16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Cartões de Receitas e Despesas (StatelessWidget CardResumo)
        Row(
          children: [
            Expanded(
              child: CardResumo(
                titulo: 'Receitas',
                valor: Formatador.moeda(receitas),
                icone: Icons.arrow_upward_rounded,
                cor: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CardResumo(
                titulo: 'Despesas',
                valor: Formatador.moeda(despesas),
                icone: Icons.arrow_downward_rounded,
                cor: const Color(0xFFE11D48),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Cabeçalho de Últimas Movimentações
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Últimas Movimentações',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton(
              onPressed: widget.aoIrParaExtrato,
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (ultimas.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Nenhuma movimentação cadastrada.'),
              ),
            ),
          )
        else
          ...ultimas.map(
            (Movimentacao mov) => ItemMovimentacao(
              movimentacao: mov,
              aoEditar: () => widget.aoEditarMovimentacao(mov),
              aoExcluir: () => widget.aoExcluirMovimentacao(mov),
            ),
          ),
      ],
    );
  }
}
