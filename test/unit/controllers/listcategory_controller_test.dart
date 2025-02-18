import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project_bdclpm/features/listcategory/controllers.dart/list_category_controller.dart';
import '../../mocks/mocks.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ListCategoryController', () {
    late ListCategoryController listCategoryController;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      listCategoryController = ListCategoryController();
      listCategoryController.httpClient = mockHttpClient; // Inject mock client
    });

    test('fetchExpenses should update expenses and totalSpent on success',
        () async {
      // Mock response
      final mockResponse = '''
      [
        {"id": "1", "totalAmount": 100.0},
        {"id": "2", "totalAmount": 200.0}
      ]
      ''';
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/123')))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      // Call the method
      await listCategoryController.fetchExpenses("123");

      // Verify results
      expect(listCategoryController.expenses.length, 2);
      expect(listCategoryController.totalSpent, 300.0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle empty response', () async {
      // Mock empty response
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/123')))
          .thenAnswer((_) async => http.Response('[]', 200));

      // Call the method
      await listCategoryController.fetchExpenses("123");

      // Verify results
      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle API error', () async {
      // Mock error response
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/123')))
          .thenAnswer((_) async => http.Response('Error', 500));

      // Call the method
      await listCategoryController.fetchExpenses("123");

      // Verify results
      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle exception', () async {
      // Mock exception
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/123')))
          .thenThrow(Exception('Network error'));

      // Call the method
      await listCategoryController.fetchExpenses("123");

      // Verify results
      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });
  });
}
