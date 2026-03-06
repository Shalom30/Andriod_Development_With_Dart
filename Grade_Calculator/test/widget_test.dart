import 'package:flutter_test/flutter_test.dart';
import 'package:grade_vault/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GradeVaultApp());
    expect(find.text('GRADE VAULT'), findsWidgets);
  });
}