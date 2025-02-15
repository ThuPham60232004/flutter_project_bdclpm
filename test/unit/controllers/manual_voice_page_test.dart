import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import '../../mocks/mocks.mocks.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/manual_voice_controllers.dart';
import 'package:http/http.dart' as http;

void main() {
  group('ExpenseManager', () {
    late ExpenseManager expenseManager;
    late MockSharedPreferences mockSharedPreferences;
    late MockSpeechToText mockSpeechToText;
    late MockClient mockHttpClient;
    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockSpeechToText = MockSpeechToText();
      mockHttpClient = MockClient();
      expenseManager = ExpenseManager(
        (message) {},
        Future.value(mockSharedPreferences),
        httpClient: mockHttpClient,
      );

      // 🔥 Đăng ký fallback values
      registerFallbackValue(Uri());
      registerFallbackValue(<String, String>{});

      when(() => mockSharedPreferences.getString(any()))
          .thenAnswer((invocation) {
        final key = invocation.positionalArguments.first;
        if (key == null) return null; // Trả về null nếu key là null
        return '123'; // Stub đúng với key hợp lệ
      });
    });

    test('fetchCategories should load categories', () async {
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => http.Response(
                json.encode([
                  {'name': 'Food', 'description': 'Eating out'}
                ]),
                200,
              ));

      await expenseManager.fetchCategories();

      expect(expenseManager.categories.length, 1);
      expect(expenseManager.categories[0]['name'], 'Food');

      verify(() => mockHttpClient.get(
            Uri.parse('https://backend-bdclpm.onrender.com/api/categories'),
          )).called(1);
    });

    test('saveExpense should save expense', () async {
      // ✅ Stub giá trị `getString('userId')` chắc chắn có dữ liệu
      when(() => mockSharedPreferences.getString('userId')).thenReturn('123');

      expenseManager.storeNameController.text = 'Store';
      expenseManager.amountController.text = '100';
      expenseManager.dateController.text = '01/01/2023';
      expenseManager.setCategory('Food');

      when(() => mockHttpClient.post(
            Uri.parse('https://backend-bdclpm.onrender.com/api/expenses'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 200));

      await expenseManager.saveExpense();

      verify(() => mockHttpClient.post(
            Uri.parse('https://backend-bdclpm.onrender.com/api/expenses'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });
  });
}
