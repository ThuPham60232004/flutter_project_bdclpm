import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project_bdclpm/features/listcategory/controllers.dart/list_category_controller.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  group('ListCategoryController', () {
    late ListCategoryController listCategoryController;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      listCategoryController = ListCategoryController();
      listCategoryController.httpClient = mockHttpClient;
    });

    test('fetchExpenses should update expenses and totalSpent on success',
        () async {
      final mockResponse = '''
      [
        {"id": "1", "totalAmount": 100.0},
        {"id": "2", "totalAmount": 200.0}
      ]
      ''';
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/123')))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      await listCategoryController.fetchExpenses("123");

      expect(listCategoryController.expenses.length, 2);
      expect(listCategoryController.totalSpent, 300.0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle empty response', () async {
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/123')))
          .thenAnswer((_) async => http.Response('[]', 200));

      await listCategoryController.fetchExpenses("123");

      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle API error', () async {
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/123')))
          .thenAnswer((_) async => http.Response('Error', 500));

      await listCategoryController.fetchExpenses("123");

      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle exception', () async {
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/123')))
          .thenThrow(Exception('Network error'));

      await listCategoryController.fetchExpenses("123");

      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });
  });
}
