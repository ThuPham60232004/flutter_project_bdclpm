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
        {
        "_id": "678d18f502455271e95277b4",
        "userId": "678cf5b1e729fb9da673725c",
        "storeName": "quan an thien tan",
        "totalAmount": 537000,
        "description": "Các mặt hàng liên quan đến thực phẩm",
        "date": "2011-11-12T17:00:00.000Z",
        "categoryId": "678cf0dfe729fb9da673724c",
        "createdAt": "2025-01-19T15:23:33.762Z",
        "updatedAt": "2025-01-19T15:23:33.762Z"
      },
      {
        "_id": "678d22dd02455271e95277b8",
        "userId": "678cf5b1e729fb9da673725c",
        "storeName": "cua hang so 1",
        "totalAmount": 3000000,
        "description": "Các mặt hàng liên quan đến thực phẩm",
        "date": "2025-01-11T17:00:00.000Z",
        "categoryId": "678cf0dfe729fb9da673724c",
        "createdAt": "2025-01-19T16:05:49.776Z",
        "updatedAt": "2025-01-19T16:05:49.776Z"
      }
      ]
      ''';
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/678d22dd02455271e95277b8')))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      await listCategoryController.fetchExpenses("678d22dd02455271e95277b8");
      
      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle empty response', () async {
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/678d22dd02455271e95277b8')))
          .thenAnswer((_) async => http.Response('[]', 200));

      await listCategoryController.fetchExpenses("");

      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle API error', () async {
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/678d22dd02455271e95277b8')))
          .thenAnswer((_) async => http.Response('Error', 500));

      await listCategoryController.fetchExpenses("678d22dd02455271e95277b8");

      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });

    test('fetchExpenses should handle exception', () async {
      when(mockHttpClient.get(Uri.parse(
              'https://backend-bdclpm.onrender.com/api/expenses/category/678d22dd02455271e95277b8')))
          .thenThrow(Exception('Network error'));

      await listCategoryController.fetchExpenses("678d22dd02455271e95277b8");

      expect(listCategoryController.expenses.length, 0);
      expect(listCategoryController.totalSpent, 0.0);
      expect(listCategoryController.isLoading, false);
    });
  });
}
