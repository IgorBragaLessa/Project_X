import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/movimentacao.dart';
import '../utils/formatador.dart';

/// StatelessWidget que representa um item da lista de movimentações.
/// Utiliza o componente extra [Dismissible] (não visto em sala) para permitir
/// arrastar o card para a esquerda para excluir com confirmação em [AlertDialog].
class ItemMovimentacao extends StatelessWidget {
  final Movimentacao movimentacao;
  final VoidCallback aoEditar;
  final VoidCallback aoExcluir;

  const ItemMovimentacao({
    super.key,
    required this.movimentacao,
    required this.aoEditar,
    required this.aoExcluir,
  });

  /// Abre um AlertDialog perguntando se o usuário confirma a exclusão.
  Future<bool?> _confirmarExclusao(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Deseja realmente excluir "${movimentacao.descricao}" '
            'no valor de ${Formatador.moeda(movimentacao.valor)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Categoria cat = Categoria.buscarPorNome(movimentacao.categoria);
    final Color corValor = movimentacao.ehReceita
        ? const Color(0xFF16A34A)
        : const Color(0xFFE11D48);
    final String prefixo = movimentacao.ehReceita ? '+ ' : '- ';

    return Dismissible(
      key: ValueKey(movimentacao.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFE11D48),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Excluir',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmarExclusao(context),
      onDismissed: (_) => aoExcluir(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          onTap: aoEditar,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cat.cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.icone, color: cat.cor, size: 22),
          ),
          title: Text(
            movimentacao.descricao,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF0F172A),
            ),
          ),
          subtitle: Text(
            '${movimentacao.categoria} • ${Formatador.data(movimentacao.data)}'
            '${movimentacao.observacao.isNotEmpty ? ' • ${movimentacao.observacao}' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$prefixo${Formatador.moeda(movimentacao.valor)}',
                style: TextStyle(
                  color: corValor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Editar movimentação',
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: aoEditar,
                ),
              ),
              Tooltip(
                message: 'Excluir movimentação',
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: Color(0xFFE11D48),
                  ),
                  onPressed: () async {
                    final bool? confirmar = await _confirmarExclusao(context);
                    if (confirmar == true) {
                      aoExcluir();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
