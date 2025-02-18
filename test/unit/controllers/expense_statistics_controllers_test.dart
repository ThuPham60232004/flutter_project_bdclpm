import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project_bdclpm/features/income/controllers/expense_statistics_controller.dart';

// Mock class cho http.Client
class MockHttpClient extends Mock implements http.Client {}

// Mock class cho SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('ExpenseStatisticsController', () {
    late ExpenseStatisticsController controller;
    late MockHttpClient mockHttpClient;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockSharedPreferences = MockSharedPreferences();
      controller = ExpenseStatisticsController();
    });

    // test('layThongKe should update thuNhap, chiTieu, and soDu when http call is successful', () async {
    //   // Arrange
    //   when(mockSharedPreferences.getString('userId')).thenReturn('123');
    //   when(mockHttpClient.get(Uri.parse('https://backend-bdclpm.onrender.com/api/expenses/statistics/123')))
    //       .thenAnswer((_) async => http.Response('{"income": 1000, "expense": 500}', 200));

    //   // Act
    //   await controller.layThongKe();

    //   // Assert
    //   expect(controller.getThuNhap(), 1000);
    //   expect(controller.getChiTieu(), 500);
    //   expect(controller.getSoDu(), 500);
    //   expect(controller.getDangTai(), false);
    // });

    // test('layThongKe should not update thuNhap, chiTieu, and soDu when http call fails', () async {
    //   // Arrange
    //   when(mockSharedPreferences.getString('userId')).thenReturn('123');
    //   when(mockHttpClient.get(Uri.parse('https://backend-bdclpm.onrender.com/api/expenses/statistics/123')))
    //       .thenAnswer((_) async => http.Response('', 404));

    //   // Act
    //   await controller.layThongKe();

    //   // Assert
    //   expect(controller.getThuNhap(), 0);
    //   expect(controller.getChiTieu(), 0);
    //   expect(controller.getSoDu(), 0);
    //   expect(controller.getDangTai(), true);
    // });

    // test('layThongKe should not update thuNhap, chiTieu, and soDu when userId is null', () async {
    //   // Arrange
    //   when(mockSharedPreferences.getString('userId')).thenReturn(null);

    //   // Act
    //   await controller.layThongKe();

    //   // Assert
    //   expect(controller.getThuNhap(), 0);
    //   expect(controller.getChiTieu(), 0);
    //   expect(controller.getSoDu(), 0);
    //   expect(controller.getDangTai(), true);
    // });
  });
}
