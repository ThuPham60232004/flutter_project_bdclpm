import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryWiseExpensesController with ChangeNotifier {
  List<dynamic> _expensesData = [];
  bool _isLoading = true;
  String? _userId;

  List<dynamic> get expensesData => _expensesData;
  bool get isLoading => _isLoading;
  String? get userId => _userId;

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null) {
      _userId = storedUserId;
      await fetchExpensesData();
    } else {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> fetchExpensesData() async {
    if (_userId == null) return;
    final String url =
        'https://backend-bdclpm.onrender.com/api/expenses/expenses-chart/$_userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _expensesData = jsonData['data'];
      } else {
        throw Exception('Failed to fetch expenses');
      }
    } catch (e) {
      print('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
