import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import '../../mocks/mocks.mocks.dart'; // Sử dụng MockClient tự tạo
import 'dart:convert';
import 'package:flutter_project_bdclpm/features/expense/controllers/manual_voice_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  late ExpenseManager expenseManager;
  late MockClient mockClient;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    mockClient = MockClient();
    SharedPreferences.setMockInitialValues({'userId': 'mockUserId'});
    sharedPreferences = await SharedPreferences.getInstance();
    expenseManager = ExpenseManager(
      (message) => debugPrint('Snackbar: $message'),
      Future.value(sharedPreferences),
      httpClient: mockClient,
    );
  });
  group('Manual Voice Controller', () {
  test('Kiểm tra tải danh mục thành công', () async {
    when(mockClient.get(
            Uri.parse('https://backend-bdclpm.onrender.com/api/categories')))
        .thenAnswer((_) async => http.Response(
              jsonEncode([
                {
                  '_id': '1',
                  'name': 'Thực phẩm',
                  'description': 'Chi tiêu ăn uống'
                }
              ]),
              200,
            ));

    await expenseManager.fetchCategories();

    expect(expenseManager.categories.isNotEmpty, true);
    expect(expenseManager.categories.first['name'], 'Thực phẩm');
  });

  test('Kiểm tra lưu chi tiêu thành công', () async {
    expenseManager.storeNameController.text = 'Quán ăn A';
    expenseManager.amountController.text = '100000';
    expenseManager.dateController.text = '01/02/2025';
    expenseManager.setCategory('Ăn uống');
    expenseManager.categories = [
      {'_id': '1', 'name': 'Ăn uống', 'description': 'Chi tiêu ăn uống'}
    ];

    when(mockClient.post(
      Uri.parse('https://backend-bdclpm.onrender.com/api/expenses'),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response('{"message":"Success"}', 201));

    await expenseManager.saveExpense();

    expect(expenseManager.storeNameController.text, 'Quán ăn A');
    expect(expenseManager.amountController.text, '100000');
    expect(expenseManager.dateController.text, '01/02/2025');
    expect(expenseManager.category, 'Ăn uống');
  });

  test('Kiểm tra thông báo lỗi khi thiếu dữ liệu', () {
    expenseManager.storeNameController.text = '';
    expenseManager.amountController.text = '';
    expenseManager.dateController.text = '';
    expenseManager.setCategory(null);

    expenseManager.saveExpense();

    expect(expenseManager.storeNameController.text.isEmpty, true);
    expect(expenseManager.amountController.text.isEmpty, true);
    expect(expenseManager.dateController.text.isEmpty, true);
    expect(expenseManager.category, null);
  });
  });
}