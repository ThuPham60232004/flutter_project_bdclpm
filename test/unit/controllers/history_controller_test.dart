import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_project_bdclpm/features/history/controllers/history_controller.dart';

// Định nghĩa các mock class
class MockClient extends Mock implements http.Client {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  // Đảm bảo binding được khởi tạo trước khi chạy test
  TestWidgetsFlutterBinding.ensureInitialized();
  late http.Client mockHttpClient;
  late SharedPreferences mockSharedPreferences;
  late HistoryController historyController;

  setUp(() {
    mockHttpClient = MockClient();
    mockSharedPreferences = MockSharedPreferences();
    historyController = HistoryController();
  });

  // group('fetchUserId', () {
  //   test('returns userId when userId is stored in SharedPreferences', () async {
  //     when(mockSharedPreferences.getString('userId')).thenReturn('12345');

  //     final userId = await historyController.fetchUserId();

  //     expect(userId, '12345');
  //     verify(mockSharedPreferences.getString('userId')).called(1);
  //   });

  //   test('returns null when userId is not stored in SharedPreferences', () async {
  //     when(mockSharedPreferences.getString('userId')).thenReturn(null);

  //     final userId = await historyController.fetchUserId();

  //     expect(userId, null);
  //     verify(mockSharedPreferences.getString('userId')).called(1);
  //   });
  // });

  // group('fetchOrderHistory', () {
  //   const String userId = '12345';
  //   final Uri testUri = Uri.parse('https://example.com/orders?userId=$userId');

  //   test('returns order history when http call succeeds', () async {
  //     when(mockHttpClient.get(testUri)).thenAnswer(
  //       (_) async => http.Response(json.encode([{'id': '1', 'amount': 100}]), 200),
  //     );

  //     final orders = await historyController.fetchOrderHistory(userId);

  //     expect(orders, isA<List<dynamic>>());
  //     expect(orders.length, 1);
  //     expect(orders[0]['id'], '1');
  //     expect(orders[0]['amount'], 100);
  //   });

  //   test('throws exception when http call fails', () async {
  //     when(mockHttpClient.get(testUri)).thenAnswer(
  //       (_) async => http.Response('Failed to load orders', 404),
  //     );

  //     expect(() async => await historyController.fetchOrderHistory(userId), throwsException);
  //   });

  //   test('returns empty list when http call throws an exception', () async {
  //     when(mockHttpClient.get(testUri)).thenThrow(Exception('Network error'));

  //     final orders = await historyController.fetchOrderHistory(userId);

  //     expect(orders, isEmpty);
  //   });
  // });
}
