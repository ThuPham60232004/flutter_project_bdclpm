import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IncomeController {
  final String apiUrl =
      "https://backend-bdclpm.onrender.com/api/gemini/income-command";
  String? userId;
  List<Map<String, String>> messages = [];
   http.Client? httpClient;
  SharedPreferences? sharedPreferences;

  // Constructor để inject dependencies
  IncomeController({this.httpClient, this.sharedPreferences});
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || userId == null) return;

    messages.add({"sender": "user", "text": message});

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": message, "userId": userId}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      messages.add({
        "sender": "bot",
        "text": jsonResponse["message"] ?? "Lỗi nhận tin nhắn"
      });
    } else {
      messages
          .add({"sender": "bot", "text": "Chatbot gặp lỗi, vui lòng thử lại!"});
    }
  }

  List<Map<String, String>> getMessages() {
    return messages;
  }
}
