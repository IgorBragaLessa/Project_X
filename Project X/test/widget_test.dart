import 'package:flutter_test/flutter_test.dart';
import 'package:project_x/controllers/movimentacao_controller.dart';
import 'package:project_x/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Project X inicializa dados de exemplo e exibe PaginaInicial',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await MovimentacaoController.carregar();

    await tester.pumpWidget(const ProjectXApp());
    await tester.pumpAndSettle();

    expect(find.text('Project X — Finanças'), findsOneWidget);
    expect(find.text('Saldo Disponível'), findsOneWidget);
  });
}
