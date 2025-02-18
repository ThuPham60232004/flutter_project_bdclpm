import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project_bdclpm/features/budget/controllers/create_budget_controller.dart'; // Correct import path
import '../../mocks/mocks.mocks.dart'; // Import generated mocks

@GenerateMocks([http.Client])
void main() {
  late CreateBudgetController controller;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    controller = CreateBudgetController();
  });

  group('getUserId', () {
    test('returns userId from SharedPreferences', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({'userId': '12345'});

      final userId = await controller.getUserId();
      expect(userId, '12345');
    });

    test('returns empty string if userId is not in SharedPreferences',
        () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      final userId = await controller.getUserId();
      expect(userId, '');
    });
  });

  group('isOverlapping', () {
    test('returns true if budget dates are overlapping', () async {
      // Mock HTTP response
      when(mockClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': '12345',
          'startBudgetDate': '2023-10-01T00:00:00.000Z',
          'endBudgetDate': '2023-10-10T00:00:00.000Z',
        }),
      )).thenAnswer((_) async => http.Response('{"isOverlapping": true}', 200));

      final isOverlapping = await controller.isOverlapping(
        '12345',
        DateTime.utc(2023, 10, 1),
        DateTime.utc(2023, 10, 10),
      );

      expect(isOverlapping, true);
    });

    test('returns false if budget dates are not overlapping', () async {
      // Mock HTTP response
      when(mockClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': '12345',
          'startBudgetDate': '2023-10-01T00:00:00.000Z',
          'endBudgetDate': '2023-10-10T00:00:00.000Z',
        }),
      )).thenAnswer(
          (_) async => http.Response('{"isOverlapping": false}', 200));

      final isOverlapping = await controller.isOverlapping(
        '12345',
        DateTime.utc(2023, 10, 1),
        DateTime.utc(2023, 10, 10),
      );

      expect(isOverlapping, false);
    });

    test('returns false on network error', () async {
      // Mock HTTP response
      when(mockClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': '12345',
          'startBudgetDate': '2023-10-01T00:00:00.000Z',
          'endBudgetDate': '2023-10-10T00:00:00.000Z',
        }),
      )).thenAnswer((_) async => http.Response('{}', 500));

      final isOverlapping = await controller.isOverlapping(
        '12345',
        DateTime.utc(2023, 10, 1),
        DateTime.utc(2023, 10, 10),
      );

      expect(isOverlapping, false);
    });
  });

  group('createBudget', () {
    test('returns true if budget is created successfully', () async {
      // Mock HTTP response
      when(mockClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': '12345',
          'amount': 1000.0,
          'startBudgetDate': '2023-10-01T00:00:00.000Z',
          'endBudgetDate': '2023-10-10T00:00:00.000Z',
        }),
      )).thenAnswer((_) async => http.Response('{}', 200));

      final isCreated = await controller.createBudget(
        '12345',
        1000.0,
        DateTime.utc(2023, 10, 1),
        DateTime.utc(2023, 10, 10),
      );

      expect(isCreated, true);
    });

    test('returns false if budget creation fails', () async {
      // Mock HTTP response
      when(mockClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': '12345',
          'amount': 1000.0,
          'startBudgetDate': '2023-10-01T00:00:00.000Z',
          'endBudgetDate': '2023-10-10T00:00:00.000Z',
        }),
      )).thenAnswer((_) async => http.Response('{}', 500));

      final isCreated = await controller.createBudget(
        '12345',
        1000.0,
        DateTime.utc(2023, 10, 1),
        DateTime.utc(2023, 10, 10),
      );

      expect(isCreated, false);
    });
  });

  group('fetchBudgets', () {
    test('returns a map of events if budgets are fetched successfully',
        () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({'userId': '12345'});

      // Mock HTTP response
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/12345'),
      )).thenAnswer((_) async => http.Response('''
        [
          {
            "startBudgetDate": "2023-10-01T00:00:00.000Z",
            "endBudgetDate": "2023-10-03T00:00:00.000Z"
          }
        ]
      ''', 200));

      final events = await controller.fetchBudgets();

      expect(events.length, 3);
      expect(events[DateTime.utc(2023, 10, 1)], ['Budget']);
      expect(events[DateTime.utc(2023, 10, 2)], ['Budget']);
      expect(events[DateTime.utc(2023, 10, 3)], ['Budget']);
    });

    test('returns an empty map if no budgets are found', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({'userId': '12345'});

      // Mock HTTP response
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/12345'),
      )).thenAnswer((_) async => http.Response('[]', 200));

      final events = await controller.fetchBudgets();

      expect(events, {});
    });

    test('returns an empty map on network error', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({'userId': '12345'});

      // Mock HTTP response
      when(mockClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/12345'),
      )).thenAnswer((_) async => http.Response('{}', 500));

      final events = await controller.fetchBudgets();

      expect(events, {});
    });
  });
}
