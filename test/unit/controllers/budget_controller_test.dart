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

    test('fetchBudgets trả về danh sách ngân sách khi statusCode = 200',
        () async {
      // Mock response thành công
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response(
            jsonEncode([
              {'id': 1, 'name': 'Ngân sách 1'},
              {'id': 2, 'name': 'Ngân sách 2'},
            ]),
            200,
            headers: {'Content-Type': 'application/json'},
          ));

      final budgets = await controller.fetchBudgets();

      expect(budgets.length, 2);
      expect(budgets[0]['name'], 'Ngân sách 1');
    });

    test('fetchBudgets ném lỗi khi statusCode khác 200', () async {
      // Mock response lỗi 500
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response('Lỗi server', 500));

      expect(() async => await controller.fetchBudgets(), throwsException);
    });

    test('fetchBudgets ném lỗi khi gặp lỗi network', () async {
      // Mock lỗi mạng
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
      )).thenThrow(Exception('Network Error'));

      expect(() async => await controller.fetchBudgets(), throwsException);
    });
  });
}
