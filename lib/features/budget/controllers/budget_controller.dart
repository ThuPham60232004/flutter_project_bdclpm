import 'dart:convert';
import 'package:http/http.dart' as http;

class BudgetController {
  Future<List<dynamic>> fetchBudgets() async {
    final response = await http.get(
      Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Không thể tải danh sách ngân sách');
    }
  }
}
