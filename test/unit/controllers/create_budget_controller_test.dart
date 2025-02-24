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
      when(mockPrefs.getString('userId')).thenReturn('12345');
      expect(await controller.getUserId(), '12345');
    });

    test('isOverlapping trả về true khi có overlap', () async {
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
              json.encode({'isOverlapping': true}), 200,
              headers: {'Content-Type': 'application/json'}));

      final result = await controller.isOverlapping(
        '12345',
        DateTime(2023, 1, 1),
        DateTime(2023, 1, 31),
      );

      expect(result, true);
    });

    test('createBudget trả về true khi tạo ngân sách thành công', () async {
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 200));

      final result = await controller.createBudget(
        '12345',
        1000.0,
        DateTime(2023, 1, 1),
        DateTime(2023, 1, 31),
      );

      expect(result, true);
    });

    test('fetchBudgets trả về Map<DateTime, List> khi fetch thành công',
        () async {
      when(mockPrefs.getString('userId')).thenReturn('12345');
      when(mockClient.get(any)).thenAnswer((_) async => http.Response(
          json.encode([
            {'startBudgetDate': '2023-01-01', 'endBudgetDate': '2023-01-02'}
          ]),
          200));

      final result = await controller.fetchBudgets();

      expect(result.length, 2);
      expect(result[DateTime(2023, 1, 1)], ['Budget']);
      expect(result[DateTime(2023, 1, 2)], ['Budget']);
    });
  });
}
