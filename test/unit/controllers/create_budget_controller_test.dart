import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_project_bdclpm/features/budget/controllers/create_budget_controller.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  group('CreateBudgetController', () {
    late MockClient mockClient;
    late MockSharedPreferences mockPrefs;
    late CreateBudgetController controller;

    setUp(() {
      mockClient = MockClient();
      mockPrefs = MockSharedPreferences();
      controller = CreateBudgetController(
        httpClient: mockClient,
        sharedPreferences: mockPrefs,
      );
    });

    test('getUserId trả về userId từ SharedPreferences', () async {
      when(mockPrefs.getString('userId'))
          .thenReturn('678e6f73037753a082ac4826');

      final result = await controller.getUserId();
      final expected = '678e6f73037753a082ac4826';

      print('Kết quả thực tế: $result - Kỳ vọng: $expected');
      expect(result, expected);
    });

    test('isOverlapping trả về true khi có overlap', () async {
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
              json.encode({'isOverlapping': true}), 200,
              headers: {'Content-Type': 'application/json'}));

      final result = await controller.isOverlapping(
        "678cf5b1e729fb9da673725c",
        DateTime.parse("2025-01-21T17:00:00.000+00:00"),
        DateTime.parse("2025-02-19T15:27:34.971+00:00"),
      );

      final expected = true;
      print('Kết quả thực tế: $result - Kỳ vọng: $expected');
      expect(result, expected);
    });

    test('isOverlapping trả về false khi không có overlap', () async {
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
              json.encode({'isOverlapping': false}), 200,
              headers: {'Content-Type': 'application/json'}));

      final result = await controller.isOverlapping(
        "678cf5b1e729fb9da673725c",
        DateTime.parse("2025-01-21T17:00:00.000+00:00"),
        DateTime.parse("2025-02-19T15:27:34.971+00:00"),
      );

      final expected = false;
      print('Kết quả thực tế: $result - Kỳ vọng: $expected');
      expect(result, expected);
    });

    test('createBudget trả về true khi tạo ngân sách thành công', () async {
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 200));

      final result = await controller.createBudget(
        "678cf5b1e729fb9da673725c",
        1000000,
        DateTime.parse("2025-01-21T17:00:00.000+00:00"),
        DateTime.parse("2025-02-19T15:27:34.971+00:00"),
      );

      final expected = true;
      print('Kết quả thực tế: $result - Kỳ vọng: $expected');
      expect(result, expected);
    });

    test('createBudget trả về false khi thất bại', () async {
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 400));

      final result = await controller.createBudget(
        "678cf5b1e729fb9da673725c",
        1000000,
        DateTime.parse("2025-01-21T17:00:00.000+00:00"),
        DateTime.parse("2025-02-19T15:27:34.971+00:00"),
      );

      final expected = false;
      print('Kết quả thực tế: $result - Kỳ vọng: $expected');
      expect(result, expected);
    });

    test('fetchBudgets trả về danh sách ngân sách hợp lệ', () async {
      when(mockPrefs.getString('userId'))
          .thenReturn('678cf5b1e729fb9da673725c');

      when(mockClient.get(any)).thenAnswer((_) async => http.Response(
          json.encode([
            {
              'startBudgetDate': '2023-01-01T00:00:00.000Z',
              'endBudgetDate': '2023-01-02T00:00:00.000Z'
            }
          ]),
          200));

      final result = await controller.fetchBudgets();

      print('Kết quả thực tế: $result');

      expect(result.isNotEmpty, true);
    });

    test('fetchBudgets trả về danh sách rỗng khi thất bại', () async {
      when(mockPrefs.getString('userId'))
          .thenReturn('678cf5b1e729fb9da673725c');

      when(mockClient.get(any)).thenAnswer((_) async => http.Response('', 500));

      final result = await controller.fetchBudgets();

      print('Kết quả thực tế: $result');

      expect(result.isEmpty, true);
    });
  });
}
