// income_controller_test.dart
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_project_bdclpm/features/history/controllers/income_history_controller.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  group('IncomeController', () {
    late IncomeController incomeController;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      incomeController = IncomeController();
    });

    // test('fetchIncomes returns a list of incomes when the http call is successful', () async {
    //   // Mock the HTTP call to return a successful response
    //   when(mockClient.get(Uri.parse(incomeController.baseUrl)))
    //       .thenAnswer((_) async => http.Response(json.encode([{'id': '1', 'amount': 100}]), 200));

    //   // Call the method under test
    //   final incomes = await incomeController.fetchIncomes();

    //   // Verify the result
    //   expect(incomes, isA<List<dynamic>>());
    //   expect(incomes.length, 1);
    //   expect(incomes[0]['id'], '1');
    //   expect(incomes[0]['amount'], 100);
    // });

    // test('fetchIncomes throws an exception when the http call fails', () async {
    //   // Mock the HTTP call to return a failed response
    //   when(mockClient.get(Uri.parse(incomeController.baseUrl)))
    //       .thenAnswer((_) async => http.Response('Not Found', 404));

    //   // Verify that the method throws an exception
    //   expect(() => incomeController.fetchIncomes(), throwsException);
    // });

    // test('deleteIncome does not throw an exception when the http call is successful', () async {
    //   // Mock the HTTP call to return a successful response
    //   when(mockClient.delete(Uri.parse('${incomeController.baseUrl}1')))
    //       .thenAnswer((_) async => http.Response('', 200));

    //   // Call the method under test
    //   await incomeController.deleteIncome('1');

    //   // Verify that no exception is thrown
    //   expect(() => incomeController.deleteIncome('1'), returnsNormally);
    // });

    test('deleteIncome throws an exception when the http call fails', () async {
      // Mock the HTTP call to return a failed response
      when(mockClient.delete(Uri.parse('${incomeController.baseUrl}1')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Verify that the method throws an exception
      expect(() => incomeController.deleteIncome('1'), throwsException);
    });

    test('calculateTotalIncome returns the correct total income', () {
      // Prepare test data
      final incomes = [
        {'id': '1', 'amount': 100},
        {'id': '2', 'amount': 200},
        {'id': '3', 'amount': 300},
      ];

      // Call the method under test
      final totalIncome = incomeController.calculateTotalIncome(incomes);

      // Verify the result
      expect(totalIncome, 600);
    });

    test('calculateTotalIncome returns 0 when the list is empty', () {
      // Prepare test data
      final incomes = [];

      // Call the method under test
      final totalIncome = incomeController.calculateTotalIncome(incomes);

      // Verify the result
      expect(totalIncome, 0);
    });

    test('calculateTotalIncome handles null amounts correctly', () {
      // Prepare test data
      final incomes = [
        {'id': '1', 'amount': 100},
        {'id': '2', 'amount': null},
        {'id': '3', 'amount': 300},
      ];

      // Call the method under test
      final totalIncome = incomeController.calculateTotalIncome(incomes);

      // Verify the result
      expect(totalIncome, 400);
    });
  });
}