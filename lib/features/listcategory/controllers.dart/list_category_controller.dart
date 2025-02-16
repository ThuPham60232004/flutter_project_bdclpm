import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListCategoryController with ChangeNotifier {
  List<dynamic> expenses = [];
  bool isLoading = true;
  double totalSpent = 0.0;
  http.Client? _httpClient;

  // Setter để inject http.Client
  set httpClient(http.Client client) {
    _httpClient = client;
  }

  // Getter để sử dụng httpClient
  http.Client get httpClient => _httpClient ?? http.Client();

  Future<void> fetchExpenses(String categoryId) async {
    try {
      final response = await httpClient.get(Uri.parse(
          'https://backend-bdclpm.onrender.com/api/expenses/category/$categoryId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        expenses = data;
        totalSpent = _calculateTotalSpent(data);
      } else {
        throw Exception('Không thể tải danh sách chi tiêu');
      }
    } catch (error) {
      expenses = [];
      totalSpent = 0.0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double _calculateTotalSpent(List<dynamic> expenses) {
    return expenses.fold(
        0.0, (sum, expense) => sum + (expense['totalAmount'] ?? 0.0));
  }
}