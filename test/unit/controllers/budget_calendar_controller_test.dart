import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project_bdclpm/features/budget/controllers/budget_calendar_controller.dart';
import 'package:flutter_project_bdclpm/features/budget/presentation/budget_calendar_page.dart';
import '../../mocks/mocks.mocks.dart';
class MockBudgetCalendarController extends Mock implements BudgetCalendarController {}

void main() {
  late MockBudgetCalendarController mockController;

  setUp(() {
    mockController = MockBudgetCalendarController();
  });

  group('BudgetCalendarPage', () {
    testWidgets('should display budget information correctly', (WidgetTester tester) async {
      final budget = {
        '_id': '1',
        'amount': 1000000,
        'startBudgetDate': '2023-10-01T00:00:00.000Z',
        'endBudgetDate': '2023-10-31T00:00:00.000Z',
      };

      when(mockController.getUserId()).thenAnswer((_) async => 'user1');
      when(mockController.checkBudgetLimit('user1', '1')).thenAnswer((_) async => {
        'message': 'Ngân sách hợp lệ',
        'status': 'valid',
        'totalExpenses': 500000,
        'expenses': [],
      });

      await tester.pumpWidget(MaterialApp(
        home: BudgetCalendarPage(budget: budget),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Ngân sách: ₫1,000,000'), findsOneWidget);
      expect(find.text('Thời gian: 01/10/2023 - 31/10/2023'), findsOneWidget);
      expect(find.text('Ngân sách hợp lệ'), findsOneWidget);
      expect(find.text('Tổng chi tiêu: ₫500,000'), findsOneWidget);
    });

    testWidgets('should display error message when userId is null', (WidgetTester tester) async {
      final budget = {
        '_id': '1',
        'amount': 1000000,
        'startBudgetDate': '2023-10-01T00:00:00.000Z',
        'endBudgetDate': '2023-10-31T00:00:00.000Z',
      };

      when(mockController.getUserId()).thenAnswer((_) async => null);

      await tester.pumpWidget(MaterialApp(
        home: BudgetCalendarPage(budget: budget),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy userId!'), findsOneWidget);
    });

    testWidgets('should display error message when API call fails', (WidgetTester tester) async {
      final budget = {
        '_id': '1',
        'amount': 1000000,
        'startBudgetDate': '2023-10-01T00:00:00.000Z',
        'endBudgetDate': '2023-10-31T00:00:00.000Z',
      };

      when(mockController.getUserId()).thenAnswer((_) async => 'user1');
      when(mockController.checkBudgetLimit('user1', '1')).thenThrow(Exception('API Error'));

      await tester.pumpWidget(MaterialApp(
        home: BudgetCalendarPage(budget: budget),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Lỗi khi tải dữ liệu: Exception: API Error'), findsOneWidget);
    });

    testWidgets('should display budget is invalid when current date is outside budget range', (WidgetTester tester) async {
      final budget = {
        '_id': '1',
        'amount': 1000000,
        'startBudgetDate': '2023-09-01T00:00:00.000Z',
        'endBudgetDate': '2023-09-30T00:00:00.000Z',
      };

      when(mockController.getUserId()).thenAnswer((_) async => 'user1');
      when(mockController.checkBudgetLimit('user1', '1')).thenAnswer((_) async => {
        'message': 'Ngân sách hợp lệ',
        'status': 'valid',
        'totalExpenses': 500000,
        'expenses': [],
      });

      await tester.pumpWidget(MaterialApp(
        home: BudgetCalendarPage(budget: budget),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Ngân sách này không còn hiệu lực!'), findsOneWidget);
    });

    testWidgets('should display expense list when expenses are available', (WidgetTester tester) async {
      final budget = {
        '_id': '1',
        'amount': 1000000,
        'startBudgetDate': '2023-10-01T00:00:00.000Z',
        'endBudgetDate': '2023-10-31T00:00:00.000Z',
      };

      when(mockController.getUserId()).thenAnswer((_) async => 'user1');
      when(mockController.checkBudgetLimit('user1', '1')).thenAnswer((_) async => {
        'message': 'Ngân sách hợp lệ',
        'status': 'valid',
        'totalExpenses': 500000,
        'expenses': [
          {'date': '2023-10-15T00:00:00.000Z', 'totalAmount': 200000},
          {'date': '2023-10-20T00:00:00.000Z', 'totalAmount': 300000},
        ],
      });

      await tester.pumpWidget(MaterialApp(
        home: BudgetCalendarPage(budget: budget),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Danh sách chi tiêu:'), findsOneWidget);
      expect(find.text('Chi tiêu: ₫200,000'), findsOneWidget);
      expect(find.text('Chi tiêu: ₫300,000'), findsOneWidget);
    });
  });
}