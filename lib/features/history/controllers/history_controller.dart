import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryController {
  Future<String?> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<List<dynamic>> fetchOrderHistory(String userId) async {
    final url =
        Uri.parse('https://backend-bdclpm.onrender.com/api/expenses/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }
}
