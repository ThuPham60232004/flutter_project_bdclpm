import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BudgetCalendarController {
  final http.Client httpClient;

  BudgetCalendarController({required this.httpClient});
  final String baseUrl = 'https://backend-bdclpm.onrender.com';

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<Map<String, dynamic>> checkBudgetLimit(
      String userId, String budgetId) async {
    try {
      final url = Uri.parse(
          '$baseUrl/api/budgets/check-budget-limit/$userId/$budgetId');
      final response = await httpClient.get(url);

      if (response.statusCode == 200 || response.statusCode == 400) {
        if (response.body.isEmpty) {
          throw Exception('Phản hồi từ server rỗng');
        }

        final data = jsonDecode(response.body);

        if (!data.containsKey('startBudgetDate') ||
            !data.containsKey('endBudgetDate') ||
            !data.containsKey('budgetAmount')) {
          throw Exception('Dữ liệu không hợp lệ từ server');
        }
        return data;
      } else {
        throw Exception('Lỗi từ server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu ngân sách: $e');
    }
  }
}
