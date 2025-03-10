import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/budget/presentation/list_budget.dart';

void main() {
  group('BudgetListPage UI Test', () {
    final mockBudgets = [
      {
        '_id': 'budget1',
        'amount': 3000000,
        'startBudgetDate': '2024-03-01',
        'endBudgetDate': '2024-03-15',
      },
      {
        '_id': 'budget2',
        'amount': 5000000,
        'startBudgetDate': '2024-03-16',
        'endBudgetDate': '2024-03-31',
      },
    ];

    testWidgets('Hiển thị tiêu đề và trạng thái loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BudgetListPage(),
        ),
      );

      expect(find.text('Danh sách Ngân sách'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Hiển thị danh sách ngân sách', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BudgetListPage(),
        ),
      );

      await tester.runAsync(() async {
        final state =
            tester.state<BudgetListPageState>(find.byType(BudgetListPage));
        state.setState(() {
          state.budgets = mockBudgets;
          state.isLoading = false;
        });
      });

      await tester.pumpAndSettle();

      expect(find.textContaining('Ngân sách'), findsNWidgets(3));
      expect(
          find.textContaining(
              NumberFormat.currency(locale: 'vi', symbol: '₫').format(3000000)),
          findsOneWidget);
      expect(
          find.textContaining(
              NumberFormat.currency(locale: 'vi', symbol: '₫').format(5000000)),
          findsOneWidget);
      expect(find.textContaining('01/03/2024 - 15/03/2024'), findsOneWidget);
      expect(find.textContaining('16/03/2024 - 31/03/2024'), findsOneWidget);
    });

    testWidgets('Hiển thị thông báo khi không có ngân sách',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BudgetListPage(),
        ),
      );

      await tester.runAsync(() async {
        final state =
            tester.state<BudgetListPageState>(find.byType(BudgetListPage));
        state.setState(() {
          state.budgets = [];
          state.isLoading = false;
        });
      });

      await tester.pumpAndSettle();

      expect(find.text('Không có ngân sách nào.'), findsOneWidget);
    });
  });
}
