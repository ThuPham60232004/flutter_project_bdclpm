import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/history/presentation/history_income.dart';

void main() {
  testWidgets('IncomeHistoryScreen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: IncomeHistoryScreen(),
      ),
    );
    expect(find.text("Lịch sử thu nhập"), findsOneWidget);
    expect(find.textContaining("Tổng thu nhập:"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
