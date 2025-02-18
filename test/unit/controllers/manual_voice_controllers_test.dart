import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../mocks/mocks.mocks.dart' hide MockClient;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/testing.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/manual_voice_controllers.dart';

void main() {
  late ExpenseManager expenseManager;
  late MockSharedPreferences mockSharedPreferences;
  late MockSpeechToText mockSpeechToText;
  late MockPermission mockPermission;
  late Function(String) showSnackBar;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockSpeechToText = MockSpeechToText();
    mockPermission = MockPermission();
    showSnackBar = (String message) => debugPrint(message);

    expenseManager = ExpenseManager(
      showSnackBar,
      Future.value(mockSharedPreferences),
      httpClient: http.Client(),
    );
  });

  // test('fetchCategories should load categories', () async {
  //   final mockResponse = http.Response(jsonEncode([
  //     {'_id': '1', 'name': 'Food', 'description': 'Food expenses'},
  //     {'_id': '2', 'name': 'Transport', 'description': 'Transport expenses'},
  //   ]), 200);

  //   when(mockSharedPreferences.getString('userId')).thenReturn('123');
  //   when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);

  //   final client = MockClient((request) async {
  //     if (request.url.toString() == 'https://backend-bdclpm.onrender.com/api/categories') {
  //       return mockResponse;
  //     }
  //     return http.Response('Not Found', 404);
  //   });

  //   expenseManager = ExpenseManager(
  //     showSnackBar,
  //     Future.value(mockSharedPreferences),
  //     httpClient: client,
  //   );

  //   await expenseManager.fetchCategories();

  //   expect(expenseManager.categories.length, 2);
  //   expect(expenseManager.isLoadingCategories, false);
  // });

  // test('updateDescription should update description based on category', () {
  //   expenseManager.categories = [
  //     {'_id': '1', 'name': 'Food', 'description': 'Food expenses'},
  //     {'_id': '2', 'name': 'Transport', 'description': 'Transport expenses'},
  //   ];

  //   expenseManager.updateDescription('Food');

  //   expect(expenseManager.descriptionController.text, 'Food expenses');
  // });

  // test('startListening should start speech recognition', () async {
  //   when(mockSpeechToText.initialize(
  //     onStatus: anyNamed('onStatus'),
  //     onError: anyNamed('onError'),
  //   )).thenAnswer((_) async => true);

  //   when(mockPermission.status).thenAnswer((_) async => PermissionStatus.granted);

  //   await expenseManager.startListening(expenseManager.storeNameController, 'storeName');

  //   expect(expenseManager.isListeningForStoreName, true);
  // });

  // test('saveExpense should save expense successfully', () async {
  //   when(mockSharedPreferences.getString('userId')).thenReturn('123');
  //   when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);

  //   final client = MockClient((request) async {
  //     if (request.url.toString() == 'https://backend-bdclpm.onrender.com/api/expenses') {
  //       return http.Response('Success', 200);
  //     }
  //     return http.Response('Not Found', 404);
  //   });

  //   expenseManager = ExpenseManager(
  //     showSnackBar,
  //     Future.value(mockSharedPreferences),
  //     httpClient: client,
  //   );

  //   expenseManager.storeNameController.text = 'Test Store';
  //   expenseManager.amountController.text = '100';
  //   expenseManager.dateController.text = '01/01/2023';
  //   expenseManager.descriptionController.text = 'Test Description';
  //   expenseManager.setCategory('Food');

  //   await expenseManager.saveExpense();

  //   expect(expenseManager.storeNameController.text, 'Test Store');
  //   expect(expenseManager.amountController.text, '100');
  //   expect(expenseManager.dateController.text, '01/01/2023');
  //   expect(expenseManager.descriptionController.text, 'Test Description');
  // });

  // test('saveExpense should show error if required fields are empty', () async {
  //   expenseManager.storeNameController.text = '';
  //   expenseManager.amountController.text = '';
  //   expenseManager.dateController.text = '';
  //   expenseManager.descriptionController.text = '';
  //   expenseManager.setCategory(null);

  //   await expenseManager.saveExpense();

  //   expect(expenseManager.storeNameController.text.isEmpty, true);
  //   expect(expenseManager.amountController.text.isEmpty, true);
  //   expect(expenseManager.dateController.text.isEmpty, true);
  //   expect(expenseManager.descriptionController.text.isEmpty, true);
  //   expect(expenseManager.category, null);
  // });
}
