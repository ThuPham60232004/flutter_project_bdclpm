import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateBudgetController {
  final http.Client httpClient;
  final SharedPreferences sharedPreferences;

  CreateBudgetController({
    required this.httpClient,
    required this.sharedPreferences,
  });

  Future<String> getUserId() async {
    return sharedPreferences.getString('userId') ?? '';
  }

  Future<bool> isOverlapping(
      String userId, DateTime startBudgetDate, DateTime endBudgetDate) async {
    final url = 'https://backend-bdclpm.onrender.com/api/budgets/';

    final response = await httpClient.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'startBudgetDate': startBudgetDate.toIso8601String(),
        'endBudgetDate': endBudgetDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['isOverlapping'] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> createBudget(String userId, double amount,
      DateTime startBudgetDate, DateTime endBudgetDate) async {
    final url = 'https://backend-bdclpm.onrender.com/api/budgets';

    final response = await httpClient.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'amount': amount,
        'startBudgetDate': startBudgetDate.toIso8601String(),
        'endBudgetDate': endBudgetDate.toIso8601String(),
      }),
    );

    return response.statusCode == 200;
  }

  Future<Map<DateTime, List>> fetchBudgets() async {
    String userId = await getUserId();
    final url = 'https://backend-bdclpm.onrender.com/api/budgets/$userId';
    final response = await httpClient.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List budgets = json.decode(response.body);
      Map<DateTime, List> events = {};

      for (var budget in budgets) {
        DateTime start = DateTime.parse(budget['startBudgetDate']);
        DateTime end = DateTime.parse(budget['endBudgetDate']);

        for (DateTime date = start;
            date.isBefore(end.add(Duration(days: 1)));
            date = date.add(Duration(days: 1))) {
          events.putIfAbsent(date, () => []).add('Budget');
        }
      }
      return events;
    } else {
      return {};
    }
  }
}
