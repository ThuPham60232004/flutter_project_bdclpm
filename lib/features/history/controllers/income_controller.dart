import 'package:http/http.dart' as http;
import 'dart:convert';

class IncomeController {
  final String baseUrl = 'https://backend-bdclpm.onrender.com/api/incomes/';

  Future<List<dynamic>> fetchIncomes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load incomes');
    }
  }

  Future<void> deleteIncome(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete income');
    }
  }

  double calculateTotalIncome(List<dynamic> incomes) {
    return incomes.fold(
        0.0, (sum, item) => sum + (item['amount']?.toDouble() ?? 0.0));
  }
}
