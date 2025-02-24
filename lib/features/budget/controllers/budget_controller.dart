import 'dart:convert';
import 'package:http/http.dart' as http;

class BudgetController {
  final http.Client httpClient;

  // Cho phép truyền httpClient từ bên ngoài để dễ mock trong test
  BudgetController({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<List<dynamic>> fetchBudgets() async {
    try {
      final response = await httpClient.get(
        Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách ngân sách: $e');
    }
  }
}
