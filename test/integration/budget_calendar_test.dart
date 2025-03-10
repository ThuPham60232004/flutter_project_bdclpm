import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/budget/presentation/budget_calendar_page.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  group('BudgetCalendarPage UI Test', () {
    final mockBudget = {
      '_id': 'budget123',
      'amount': 5000000,
      'startBudgetDate': '2024-03-01',
      'endBudgetDate': '2024-03-31',
    };

    testWidgets('Hiển thị thông tin ngân sách và thông báo',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BudgetCalendarPage(budget: mockBudget),
        ),
      );

      expect(find.text('Cảnh báo ngân sách'), findsOneWidget);
      expect(find.textContaining('Ngân sách:'), findsOneWidget);
      expect(
          find.textContaining(
              NumberFormat.currency(locale: 'vi', symbol: '₫').format(5000000)),
          findsOneWidget);
      expect(find.textContaining('Thời gian: 01/03/2024 - 31/03/2024'),
          findsOneWidget);
    });

    testWidgets(
        'Hiển thị thông báo không có khoản chi tiêu khi danh sách trống',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BudgetCalendarPage(budget: mockBudget),
        ),
      );

      expect(find.text('Không có khoản chi tiêu nào.'), findsOneWidget);
    });

    testWidgets('Hiển thị lịch', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BudgetCalendarPage(budget: mockBudget),
        ),
      );

      expect(find.byWidgetPredicate((widget) => widget is TableCalendar),
          findsOneWidget);
    });
  });
}
