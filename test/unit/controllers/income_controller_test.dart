import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/income/controllers/income_controller.dart'; // Điều chỉnh import theo project của bạn
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../mocks/mocks.mocks.dart';

@GenerateMocks([http.Client, SharedPreferences])
void main() {
  group('IncomeController', () {
    late IncomeController incomeController;
    late MockClient mockHttpClient;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockHttpClient = MockClient();
      mockSharedPreferences = MockSharedPreferences();
      incomeController = IncomeController();
      incomeController.httpClient = mockHttpClient;
      incomeController.sharedPreferences = mockSharedPreferences;
    });

    // test('loadUserId should load userId from SharedPreferences', () async {
    //   when(mockSharedPreferences.getString("userId")).thenReturn("12345");

    //   await incomeController.loadUserId();

    //   expect(incomeController.userId, "12345");
    // });

    test('sendMessage should not send message if message is empty', () async {
      incomeController.userId = "12345";

      await incomeController.sendMessage("");

      expect(incomeController.getMessages().length, 0);
    });

    test('sendMessage should not send message if userId is null', () async {
      incomeController.userId = null;

      await incomeController.sendMessage("Hello");

      expect(incomeController.getMessages().length, 0);
    });

    // test('sendMessage should add user message to messages list', () async {
    //   incomeController.userId = "12345";

    //   await incomeController.sendMessage("Hello");

    //   expect(incomeController.getMessages().length, 1);
    //   expect(incomeController.getMessages()[0]["sender"], "user");
    //   expect(incomeController.getMessages()[0]["text"], "Hello");
    // });

    // test('sendMessage should add bot response to messages list on success', () async {
    //   incomeController.userId = "12345";
    //   when(mockHttpClient.post(
    //     Uri.parse("https://backend-bdclpm.onrender.com/api/gemini/income-command"),
    //     headers: anyNamed("headers"),
    //     body: anyNamed("body"),
    //   )).thenAnswer((_) async => http.Response('{"message": "Hi there!"}', 200));

    //   await incomeController.sendMessage("Hello");

    //   expect(incomeController.getMessages().length, 2);
    //   expect(incomeController.getMessages()[1]["sender"], "bot");
    //   expect(incomeController.getMessages()[1]["text"], "Hi there!");
    // });

    // test('sendMessage should add error message to messages list on failure', () async {
    //   incomeController.userId = "12345";
    //   when(mockHttpClient.post(
    //     Uri.parse("https://backend-bdclpm.onrender.com/api/gemini/income-command"),
    //     headers: anyNamed("headers"),
    //     body: anyNamed("body"),
    //   )).thenAnswer((_) async => http.Response('{}', 500));

    //   await incomeController.sendMessage("Hello");

    //   expect(incomeController.getMessages().length, 2);
    //   expect(incomeController.getMessages()[1]["sender"], "bot");
    //   expect(incomeController.getMessages()[1]["text"], "Chatbot gặp lỗi, vui lòng thử lại!");
    // });
  });
}
