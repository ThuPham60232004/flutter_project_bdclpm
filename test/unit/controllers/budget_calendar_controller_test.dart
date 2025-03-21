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
          .thenReturn('678cf5b1e729fb9da673725c');

      SharedPreferences.setMockInitialValues(
          {'userId': '678cf5b1e729fb9da673725c'});

      final userId = await budgetController.getUserId();

      bool isUserIdCorrect = userId == '678cf5b1e729fb9da673725c';
      print("✅ Kiểm tra userId từ SharedPreferences: $isUserIdCorrect");

      expect(isUserIdCorrect, true);
    });

    test('Kiểm tra ngân sách thành công khi status code là 200', () async {
      final userId = '678cf5b1e729fb9da673725c';
      final budgetId = '67ad84549c848251f0a59a80';

      final mockResponse = {
        'startBudgetDate': '2025-02-22T00:00:00.000+00:00',
        'endBudgetDate': '2025-03-29T00:00:00.000+00:00',
        'budgetAmount': 1000
      };

      final expectedUrl = Uri.parse(
          'https://backend-bdclpm.onrender.com/api/budgets/check-budget-limit/$userId/$budgetId');

      when(mockHttpClient.get(expectedUrl, headers: anyNamed('headers')))
          .thenAnswer(
              (_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await budgetController.checkBudgetLimit(userId, budgetId);

      bool isResponseCorrect = result.toString() == mockResponse.toString();
      print("✅ Kết quả từ API: $result");
      print("✅ Kết quả mong đợi: $mockResponse");
      print("✅ So sánh kết quả: $isResponseCorrect");

      expect(isResponseCorrect, true);
    });
    test('Ném Exception khi server trả về mã trạng thái khác 200 hoặc 400',
        () async {
      final userId = '678cf5b1e729fb9da673725c';
      final budgetId = '678e6f73037753a082ac4826';

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('Lỗi server', 500),
      );

      bool throwsError = false;
      try {
        await budgetController.checkBudgetLimit(userId, budgetId);
      } catch (e) {
        throwsError = true;
      }

      print("⚠️ Kiểm tra lỗi HTTP 500: $throwsError");
      expect(throwsError, true);
    });

    test('Ném Exception khi dữ liệu từ server thiếu các trường bắt buộc',
        () async {
      final userId = '678cf5b1e729fb9da673725c';
      final _id = '678e6f73037753a082ac4826';

      final mockInvalidResponse = {
        "_id": "67ad84549c848251f0a59a80",
        "amount": 30000000,
        "startBudgetDate": "2025-02-22T00:00:00.000Z",
        "endBudgetDate": "2025-03-29T00:00:00.000Z",
        "createdAt": "2025-02-13T05:34:12.035Z",
        "updatedAt": "2025-02-13T05:34:12.035Z"
      };
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockInvalidResponse), 200),
      );

      bool throwsError = false;
      try {
        await budgetController.checkBudgetLimit(userId, _id);
      } catch (e) {
        throwsError = true;
      }

      print("⚠️ Kiểm tra lỗi JSON thiếu trường: $throwsError");
      expect(throwsError, true);
    });

    test('Ném Exception khi lỗi kết nối tới server', () async {
      final userId = '678cf5b1e729fb9da673725c';
      final budgetId = '678e6f73037753a082ac4826';

      when(mockHttpClient.get(any)).thenThrow(Exception('Lỗi kết nối'));

      bool throwsError = false;
      try {
        await budgetController.checkBudgetLimit(userId, budgetId);
      } catch (e) {
        throwsError = true;
      }

      print("⚠️ Kiểm tra lỗi kết nối: $throwsError");
      expect(throwsError, true);
    });

    test('Ném Exception khi User ID hoặc Budget ID null hoặc rỗng', () async {
      bool throwsError1 = false;
      bool throwsError2 = false;
      bool throwsError3 = false;
      bool throwsError4 = false;

      try {
        await budgetController.checkBudgetLimit('', '67ad84549c848251f0a59a80');
      } catch (e) {
        throwsError1 = true;
      }

      try {
        await budgetController.checkBudgetLimit('678cf5b1e729fb9da673725c', '');
      } catch (e) {
        throwsError2 = true;
      }

      try {
        await budgetController.checkBudgetLimit('', '');
      } catch (e) {
        throwsError3 = true;
      }

      try {
        await budgetController.checkBudgetLimit('678cf5b1e729fb9da673725c', '');
      } catch (e) {
        throwsError4 = true;
      }

      print("⚠️ Kiểm tra lỗi User ID rỗng: $throwsError1");
      print("⚠️ Kiểm tra lỗi Budget ID rỗng: $throwsError2");
      print("⚠️ Kiểm tra lỗi cả 2 ID rỗng: $throwsError3");
      print("⚠️ Kiểm tra lỗi Budget ID rỗng (trường hợp 2): $throwsError4");

      expect(throwsError1, true);
      expect(throwsError2, true);
      expect(throwsError3, true);
      expect(throwsError4, true);
    });

    test('Ném Exception khi dữ liệu JSON từ server không thể parse được',
        () async {
      final userId = '678cf5b1e729fb9da673725c';
      final budgetId = '678e6f73037753a082ac4826';

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('Dữ liệu không phải JSON', 200),
      );

      bool throwsError = false;
      try {
        await budgetController.checkBudgetLimit(userId, budgetId);
      } catch (e) {
        throwsError = true;
      }

      print("⚠️ Kiểm tra lỗi JSON không hợp lệ: $throwsError");
      expect(throwsError, true);
    });
  });
}
