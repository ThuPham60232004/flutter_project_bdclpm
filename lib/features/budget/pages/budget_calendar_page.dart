import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class BudgetCalendarPage extends StatefulWidget {
  final Map<String, dynamic> budget;

  const BudgetCalendarPage({required this.budget});

  @override
  _BudgetCalendarPageState createState() => _BudgetCalendarPageState();
}

class _BudgetCalendarPageState extends State<BudgetCalendarPage> {
  String _message = '';
  bool _isOverBudget = false;
  double _totalExpenses = 0.0;
  List<dynamic> _expenses = [];

  @override
  void initState() {
    super.initState();
    _checkBudgetLimit();
  }

  // Hàm lấy userId từ shared_preferences
  Future<String?> _getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _checkBudgetLimit() async {
    final userId = await _getUserId();
    if (userId == null) {
      setState(() {
        _message = 'Không tìm thấy userId!';
      });
      return;
    }

    final url =
        'https://backend-bdclpm.onrender.com/api/budgets/check-budget-limit/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _message = data['message'];
          _isOverBudget = false;
          _totalExpenses = data['totalExpenses'].toDouble();
          _expenses = data['expenses'];
        });
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        setState(() {
          _message = 'Chi tiêu vượt quá ngân sách';
          _isOverBudget = true;
          _totalExpenses = data['totalExpenses'].toDouble();
          _expenses = data['expenses'];
        });
      }
    } catch (error) {
      setState(() {
        _message = 'Lỗi kết nối mạng!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double amount = (widget.budget['amount'] is int)
        ? (widget.budget['amount'] as int).toDouble()
        : widget.budget['amount']?.toDouble() ?? 0.0;

    final startBudgetDate = DateTime.parse(widget.budget['startBudgetDate']);
    final endBudgetDate = DateTime.parse(widget.budget['endBudgetDate']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cảnh báo khi người dùng vượt ngân sách'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ngân sách: ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(amount)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thời gian: ${DateFormat('dd/MM/yyyy').format(startBudgetDate)} - ${DateFormat('dd/MM/yyyy').format(endBudgetDate)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(
                fontSize: 16,
                color: _isOverBudget ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tổng chi tiêu: ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(_totalExpenses)}',
              style: TextStyle(
                fontSize: 16,
                color: _isOverBudget ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            _buildCalendar(startBudgetDate, endBudgetDate),
            const SizedBox(height: 20),
            _buildExpenseList(),
          ],
        )),
      ),
    );
  }

  // Hàm tạo lịch
  Widget _buildCalendar(DateTime startDate, DateTime endDate) {
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      focusedDay: DateTime.now(),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: const Color.fromARGB(255, 247, 224, 191),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: const Color.fromARGB(255, 179, 227, 181),
          shape: BoxShape.rectangle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (date.isAfter(startDate.subtract(Duration(days: 1))) &&
              date.isBefore(endDate.add(Duration(days: 1)))) {
            return Container(
              margin: const EdgeInsets.all(0.1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
                shape: BoxShape.rectangle,
              ),
              child: Text(
                '${date.day}',
                style: const TextStyle(color: Colors.black),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildExpenseList() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh sách chi tiêu:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ..._expenses.map((expense) {
          final expenseDate = DateTime.parse(expense['date']);
          return ListTile(
            title: Text(
              'Chi tiêu: ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(expense['totalAmount'])}',
            ),
            subtitle: Text(
              'Ngày: ${DateFormat('dd/MM/yyyy').format(expenseDate)}',
            ),
            trailing: Icon(Icons.money),
          );
        }).toList(),
      ],
    ));
  }
}
