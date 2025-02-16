import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/listcategory/controllers.dart/category_wise_expenses_controller.dart'; 
import '../../mocks/mocks.mocks.dart';

void main() {
  // Khởi tạo binding
  TestWidgetsFlutterBinding.ensureInitialized();

  late CategoryWiseExpensesController controller;
  late MockSharedPreferences mockSharedPreferences;
  late MockClient mockHttpClient;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockHttpClient = MockClient();
    controller = CategoryWiseExpensesController();
  });

  group('CategoryWiseExpensesController', () {
    // test('loadUserId should load userId and fetch expenses data', () async {
    //   // Arrange
    //   when(mockSharedPreferences.getString('userId')).thenReturn('123');
    //   when(mockHttpClient.get(Uri.parse('https://backend-bdclpm.onrender.com/api/expenses/expenses-chart/123')))
    //       .thenAnswer((_) async => http.Response(json.encode({'data': []}), 200));

    //   // Act
    //   await controller.loadUserId();

    //   // Assert
    //   expect(controller.userId, '123');
    //   expect(controller.expensesData, []);
    //   expect(controller.isLoading, false);
    // });

    // test('loadUserId should set isLoading to false if userId is null', () async {
    //   // Arrange
    //   when(mockSharedPreferences.getString('userId')).thenReturn(null);

    //   // Act
    //   await controller.loadUserId();

    //   // Assert
    //   expect(controller.userId, isNull);
    //   expect(controller.isLoading, false);
    // });

    // test('fetchExpensesData should fetch expenses data', () async {
    //   // Arrange
    //   // Sử dụng setter công khai để thiết lập userId
    //   controller.userId = '123';
    //   when(mockHttpClient.get(Uri.parse('https://backend-bdclpm.onrender.com/api/expenses/expenses-chart/123')))
    //       .thenAnswer((_) async => http.Response(json.encode({'data': [{'category': 'Food', 'amount': 100}]}), 200));

    //   // Act
    //   await controller.fetchExpensesData();

    //   // Assert
    //   expect(controller.expensesData, [{'category': 'Food', 'amount': 100}]);
    //   expect(controller.isLoading, false);
    // });

    test('fetchExpensesData should handle errors', () async {
      // Arrange
      // Sử dụng setter công khai để thiết lập userId
      controller.userId = '123';
      when(mockHttpClient.get(Uri.parse('https://backend-bdclpm.onrender.com/api/expenses/expenses-chart/123')))
          .thenThrow(Exception('Failed to fetch expenses'));

      // Act
      await controller.fetchExpensesData();

      // Assert
      expect(controller.expensesData, []);
      expect(controller.isLoading, false);
    });
  });
}