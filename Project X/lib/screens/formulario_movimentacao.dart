import 'package:flutter/material.dart';
import '../controllers/movimentacao_controller.dart';
import '../models/categoria.dart';
import '../models/movimentacao.dart';
import '../utils/formatador.dart';

/// Tela de formulário (StatefulWidget) para cadastrar ou editar uma Movimentação.
/// Utiliza TextEditingController (com dispose), RadioListTile (RadioButton),
/// DropdownButtonFormField, showDatePicker (componente extra), ElevatedButton e SnackBar.
class FormularioMovimentacao extends StatefulWidget {
  final Movimentacao? movimentacaoExistente;
  final String tipoInicial;

  const FormularioMovimentacao({
    super.key,
    this.movimentacaoExistente,
    this.tipoInicial = 'despesa',
  });

  @override
  State<FormularioMovimentacao> createState() => _FormularioMovimentacaoState();
}

class _FormularioMovimentacaoState extends State<FormularioMovimentacao> {
  late TextEditingController _descricaoCtrl;
  late TextEditingController _valorCtrl;
  late TextEditingController _observacaoCtrl;

  late String _tipoSelecionado;
  late String _categoriaSelecionada;
  late DateTime _dataSelecionada;

  bool get _estaEditando => widget.movimentacaoExistente != null;

  @override
  void initState() {
    super.initState();
    final Movimentacao? mov = widget.movimentacaoExistente;

    _tipoSelecionado = mov?.tipo ?? widget.tipoInicial;
    _dataSelecionada = mov?.data ?? DateTime.now();

    _descricaoCtrl = TextEditingController(text: mov?.descricao ?? '');
    _valorCtrl = TextEditingController(
      text: mov != null ? mov.valor.toStringAsFixed(2).replaceAll('.', ',') : '',
    );
    _observacaoCtrl = TextEditingController(text: mov?.observacao ?? '');

    final List<Categoria> opcoes = Categoria.porTipo(_tipoSelecionado);
    if (mov != null && opcoes.any((c) => c.nome == mov.categoria)) {
      _categoriaSelecionada = mov.categoria;
    } else {
      _categoriaSelecionada = opcoes.first.nome;
    }
  }

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    _observacaoCtrl.dispose();
    super.dispose();
  }

  /// Altera o tipo ('despesa' ou 'receita') via RadioButton e atualiza a categoria padrão.
  void _alterarTipo(String? novoTipo) {
    if (novoTipo == null) return;
    setState(() {
      _tipoSelecionado = novoTipo;
      _categoriaSelecionada = Categoria.porTipo(_tipoSelecionado).first.nome;
    });
  }

  /// Abre o calendário nativo do Flutter (showDatePicker - componente extra).
  Future<void> _selecionarData() async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (escolhida != null) {
      setState(() {
        _dataSelecionada = escolhida;
      });
    }
  }

  /// Valida os campos, salva no MovimentacaoController e exibe SnackBar.
  Future<void> _salvar() async {
    final String descricao = _descricaoCtrl.text.trim();
    final double? valor = Formatador.converterValor(_valorCtrl.text);

    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma descrição para a movimentação.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor numérico maior que zero.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    final Movimentacao registro = Movimentacao(
      id: widget.movimentacaoExistente?.id ??
          'mov_${DateTime.now().millisecondsSinceEpoch}',
      descricao: descricao,
      valor: valor,
      data: _dataSelecionada,
      tipo: _tipoSelecionado,
      categoria: _categoriaSelecionada,
      observacao: _observacaoCtrl.text.trim(),
    );

    if (_estaEditando) {
      await MovimentacaoController.editar(registro);
    } else {
      await MovimentacaoController.incluir(registro);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _estaEditando
              ? 'Movimentação atualizada com sucesso!'
              : 'Movimentação registrada com sucesso!',
        ),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final List<Categoria> categoriasDisponiveis =
        Categoria.porTipo(_tipoSelecionado);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _estaEditando ? 'Editar Movimentação' : 'Nova Movimentação',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tipo de Lançamento',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Uso de RadioListTile (RadioButton visto em sala)
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Despesa'),
                            value: 'despesa',
                            groupValue: _tipoSelecionado,
                            activeColor: const Color(0xFFE11D48),
                            contentPadding: EdgeInsets.zero,
                            onChanged: _alterarTipo,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Receita'),
                            value: 'receita',
                            groupValue: _tipoSelecionado,
                            activeColor: const Color(0xFF16A34A),
                            contentPadding: EdgeInsets.zero,
                            onChanged: _alterarTipo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Campo de Descrição com TextEditingController
                    TextField(
                      controller: _descricaoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (ex: Almoço, Salário)',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo de Valor com TextEditingController
                    TextField(
                      controller: _valorCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Valor (R\$)',
                        hintText: 'Ex: 150,00',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seleção de Categoria
                    DropdownButtonFormField<String>(
                      value: _categoriaSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categoriasDisponiveis.map((Categoria cat) {
                        return DropdownMenuItem<String>(
                          value: cat.nome,
                          child: Row(
                            children: [
                              Icon(cat.icone, color: cat.cor, size: 20),
                              const SizedBox(width: 10),
                              Text(cat.nome),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? nova) {
                        if (nova != null) {
                          setState(() {
                            _categoriaSelecionada = nova;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Seletor de Data com showDatePicker
                    InkWell(
                      onTap: _selecionarData,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data da Movimentação',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(Formatador.data(_dataSelecionada)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo opcional de Observação
                    TextField(
                      controller: _observacaoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Observação (opcional)',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão de Gravar (ElevatedButton visto em sala)
                    ElevatedButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.check),
                      label: Text(
                        _estaEditando ? 'Salvar Alterações' : 'Gravar Lançamento',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
