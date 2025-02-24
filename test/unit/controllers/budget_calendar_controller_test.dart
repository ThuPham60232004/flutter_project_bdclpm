import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project_bdclpm/features/budget/controllers/budget_calendar_controller.dart';
import '../../mocks/mocks.mocks.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../test_config.dart';

void main() {
  setupTestEnvironment();
  late BudgetCalendarController budgetController;
  late MockSharedPreferences mockSharedPreferences;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    budgetController = BudgetCalendarController(httpClient: mockHttpClient);
    mockSharedPreferences = MockSharedPreferences();
  });

  group('BudgetCalendarController', () {
    test('getUserId trả về đúng userId từ SharedPreferences', () async {
      when(mockSharedPreferences.getString('userId'))
          .thenReturn('test_user_id');

      SharedPreferences.setMockInitialValues({'userId': 'test_user_id'});

      final userId = await budgetController.getUserId();

      expect(userId, 'test_user_id');
    });

    test('Kiểm tra ngân sách thành công khi status code là 200', () async {
      final userId = 'test_user_id';
      final budgetId = 'test_budget_id';

      final mockResponse = {
        'startBudgetDate': '2023-01-01',
        'endBudgetDate': '2023-12-31',
        'budgetAmount': 1000
      };

      final expectedUrl = Uri.parse(
          'https://backend-bdclpm.onrender.com/api/budgets/check-budget-limit/$userId/$budgetId');

      when(mockHttpClient.get(expectedUrl, headers: anyNamed('headers')))
          .thenAnswer(
              (_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await budgetController.checkBudgetLimit(userId, budgetId);

      expect(result, mockResponse);
    });

    test('Ném Exception khi server trả về mã trạng thái khác 200 hoặc 400',
        () async {
      final userId = 'test_user_id';
      final budgetId = 'test_budget_id';

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('Lỗi server', 500),
      );

      expect(
        () async => await budgetController.checkBudgetLimit(userId, budgetId),
        throwsA(isA<Exception>()),
      );
    });

    test('Ném Exception khi dữ liệu từ server thiếu các trường bắt buộc',
        () async {
      final userId = 'test_user_id';
      final budgetId = 'test_budget_id';

      final mockInvalidResponse = {'invalidField': 'invalidData'};

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockInvalidResponse), 200),
      );

      expect(
        () async => await budgetController.checkBudgetLimit(userId, budgetId),
        throwsA(isA<Exception>()),
      );
    });

    test('Ném Exception khi lỗi kết nối tới server', () async {
      final userId = 'test_user_id';
      final budgetId = 'test_budget_id';

      when(mockHttpClient.get(any)).thenThrow(Exception('Lỗi kết nối'));

      expect(
        () async => await budgetController.checkBudgetLimit(userId, budgetId),
        throwsA(isA<Exception>()),
      );
    });

    test('Ném Exception khi User ID hoặc Budget ID null hoặc rỗng', () async {
      expect(
        () async => await budgetController.checkBudgetLimit('', 'budget_id'),
        throwsA(isA<Exception>()),
      );

      expect(
        () async => await budgetController.checkBudgetLimit('user_id', ''),
        throwsA(isA<Exception>()),
      );

      expect(
        () async => await budgetController.checkBudgetLimit('', ''),
        throwsA(isA<Exception>()),
      );

      expect(
        () async => await budgetController.checkBudgetLimit('user_id', ''),
        throwsA(isA<Exception>()),
      );
    });

    test('Ném Exception khi dữ liệu JSON từ server không thể parse được',
        () async {
      final userId = 'test_user_id';
      final budgetId = 'test_budget_id';

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('Dữ liệu không phải JSON', 200),
      );

      expect(
        () async => await budgetController.checkBudgetLimit(userId, budgetId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
