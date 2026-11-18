import 'package:flutter/material.dart';
import 'controllers/movimentacao_controller.dart';
import 'screens/pagina_inicial.dart';

/// Ponto de entrada da aplicação.
/// Garante a inicialização do Flutter e carrega os dados do SharedPreferences.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MovimentacaoController.carregar();
  runApp(const ProjectXApp());
}

/// Widget raiz da aplicação (StatelessWidget).
/// Configura o MaterialApp e o tema visual clean em tons de verde-esmeralda.
class ProjectXApp extends StatelessWidget {
  const ProjectXApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color corPrimaria = Color(0xFF16A34A);
    const Color corFundo = Color(0xFFF6F8F7);
    const Color corBorda = Color(0xFFE6EAE8);

    return MaterialApp(
      title: 'Project X — Controle Financeiro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: corFundo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: corPrimaria,
          primary: corPrimaria,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: corBorda, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: corBorda),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: corBorda),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corPrimaria,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const PaginaInicial(),
    );
  }
}
