import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project_bdclpm/features/budget/controllers/budget_controller.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  group('BudgetController', () {
    late MockClient mockClient;
    late BudgetController controller;

    setUp(() {
      mockClient = MockClient();
      controller = BudgetController(httpClient: mockClient);
    });

    test('fetchBudgets trả về danh sách ngân sách khi statusCode là 200', () async {
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response(
            jsonEncode([
              {
                "_id": "678e6f73037753a082ac4826",
                "userId": "678cf5b1e729fb9da673725c",
                "amount": 1000000,
                "startBudgetDate": "2025-01-21T17:00:00.000+00:00",
                "endBudgetDate": "2025-02-19T15:27:34.971+00:00",
                "createdAt": "2025-01-20T15:44:51.355+00:00",
                "updatedAt": "2025-01-20T15:44:51.355+00:00"
              },
              {
                "_id": "67ad84549c848251f0a59a80",
                "userId": "678cf5b1e729fb9da673725c",
                "amount": 30000000,
                "startBudgetDate": "2025-02-22T00:00:00.000+00:00",
                "endBudgetDate": "2025-03-29T00:00:00.000+00:00",
                "createdAt": "2025-02-13T05:34:12.035+00:00",
                "updatedAt": "2025-02-13T05:34:12.035+00:00"
              }
            ]),
            200,
            headers: {'Content-Type': 'application/json'},
          ));

      final budgets = await controller.fetchBudgets();

      bool isLengthCorrect = budgets.length == 2;
      bool isFirstAmountCorrect = budgets[0]['amount'] == 1000000;

      print("✅ Kiểm tra số lượng phần tử: ${isLengthCorrect}");
      print("✅ Kiểm tra amount phần tử đầu tiên: ${isFirstAmountCorrect}");

      expect(isLengthCorrect, true);
      expect(isFirstAmountCorrect, true);
    });

    test('fetchBudgets ném lỗi khi statusCode khác 200', () async {
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response('Lỗi server', 500));

      bool throwsError = false;
      try {
        await controller.fetchBudgets();
      } catch (e) {
        throwsError = true;
      }

      print("⚠️ Kiểm tra lỗi khi statusCode != 200: Cacth Lỗi${throwsError}");
      expect(throwsError, true);
    });

    test('fetchBudgets ném lỗi khi gặp lỗi network', () async {
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
      )).thenThrow(Exception('Network Error'));

      bool throwsError = false;
      try {
        await controller.fetchBudgets();
      } catch (e) {
        throwsError = true;
      }

      print("⚠️ Kiểm tra lỗi khi gặp Network Error: Cacth Lỗi${throwsError}");
      expect(throwsError, true);
    });
  });
}
