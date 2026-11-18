/// Classe utilitária para formatação de moeda (R$) e datas (dd/MM/yyyy).
class Formatador {
  /// Formata um número double para o padrão monetário brasileiro: R$ 1.234,56
  static String moeda(double valor) {
    final bool negativo = valor < 0;
    final double absoluto = valor.abs();
    final List<String> partes = absoluto.toStringAsFixed(2).split('.');
    final String parteInteira = partes[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    final String resultado = 'R\$ $parteInteira,${partes[1]}';
    return negativo ? '-$resultado' : resultado;
  }

  /// Formata um DateTime para o padrão brasileiro: dd/MM/yyyy
  static String data(DateTime data) {
    final String dia = data.day.toString().padLeft(2, '0');
    final String mes = data.month.toString().padLeft(2, '0');
    final String ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  /// Converte um texto digitado pelo usuário (ex: "150,50" ou "150.50") em double.
  static double? converterValor(String texto) {
    String limpo = texto.trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (limpo.isEmpty) return null;

    if (limpo.contains(',') && limpo.contains('.')) {
      limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
    } else if (limpo.contains(',')) {
      limpo = limpo.replaceAll(',', '.');
    }
    return double.tryParse(limpo);
  }
}
