import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project_bdclpm/features/budget/controllers/budget_calendar_controller.dart';

// Mock classes
class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Khởi tạo binding
  group('BudgetCalendarController', () {
    late BudgetCalendarController controller;
    late MockClient mockHttpClient;
    final String baseUrl = 'https://backend-bdclpm.onrender.com';

    setUp(() {
      mockHttpClient = MockClient();
      controller = BudgetCalendarController();

      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'userId': '12345', // Mock giá trị cho 'userId'
      });
    });

    test('getUserId returns userId from SharedPreferences', () async {
      final userId = await controller.getUserId();
      expect(userId, '12345');
    });

    // test('checkBudgetLimit returns valid data on successful response', () async {
    //   final mockResponse = {
    //     'startBudgetDate': '2023-10-01',
    //     'endBudgetDate': '2023-10-31',
    //     'budgetAmount': 1000.0
    //   };
    //   final url = Uri.parse('$baseUrl/api/budgets/check-budget-limit/12345/budget123');

    //   // Thiết lập hành vi cho mockHttpClient
    //   when(mockHttpClient.get(url)).thenAnswer((_) async =>
    //       http.Response(jsonEncode(mockResponse), 200));

    //   final result = await controller.checkBudgetLimit('12345', 'budget123');
    //   expect(result, mockResponse);
    // });

    // test('checkBudgetLimit throws exception on invalid data', () async {
    //   final mockResponse = {
    //     'startBudgetDate': '2023-10-01',
    //     // Missing 'endBudgetDate' and 'budgetAmount'
    //   };
    //   final url = Uri.parse('$baseUrl/api/budgets/check-budget-limit/12345/budget123');

    //   // Thiết lập hành vi cho mockHttpClient
    //   when(mockHttpClient.get(url)).thenAnswer((_) async =>
    //       http.Response(jsonEncode(mockResponse), 200));

    //   expect(() async => await controller.checkBudgetLimit('12345', 'budget123'),
    //       throwsA(isA<Exception>()));
    // });

    // test('checkBudgetLimit throws exception on server error', () async {
    //   final url = Uri.parse('$baseUrl/api/budgets/check-budget-limit/12345/budget123');

    //   // Thiết lập hành vi cho mockHttpClient
    //   when(mockHttpClient.get(url)).thenAnswer((_) async =>
    //       http.Response('Error', 500));

    //   expect(() async => await controller.checkBudgetLimit('12345', 'budget123'),
    //       throwsA(isA<Exception>()));
    // });
  });
}
