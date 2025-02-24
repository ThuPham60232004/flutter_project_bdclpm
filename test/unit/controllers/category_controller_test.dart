import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_project_bdclpm/features/listcategory/controllers.dart/category_controller.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CategoryController controller;
  late MockSharedPreferences mockSharedPreferences;
  late MockClient mockHttpClient;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockHttpClient = MockClient();
    controller = CategoryController();
  });

  group('CategoryController', () {
    // test('fetchCategories should load categories correctly', () async {
    //   // Arrange
    //   when(mockHttpClient.get(Uri.parse('https://backend-bdclpm.onrender.com/api/categories')))
    //       .thenAnswer((_) async => http.Response(
    //         json.encode([
    //           {"name": "Thực phẩm", "icon": "food"},
    //           {"name": "Điện tử", "icon": "devices"}
    //         ]), 200));
    //   await controller.fetchCategories();
    //   expect(controller.categories.map((c) => c.name).toList(), ["Thực phẩm", "Điện tử"]);
    //   expect(controller.isLoading, false);
    // });

    // test('fetchCategories should handle errors', () async {
    //   when(mockHttpClient.get(Uri.parse('https://backend-bdclpm.onrender.com/api/categories')))
    //       .thenThrow(Exception('Failed to fetch categories'));
    //   expect(() async => await controller.fetchCategories(), throwsException);
    //   expect(controller.categories, []);
    //   expect(controller.isLoading, false);
    // });
  });
}
