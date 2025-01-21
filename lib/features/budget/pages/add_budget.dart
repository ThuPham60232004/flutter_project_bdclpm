import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CreateBudgetScreen extends StatefulWidget {
  @override
  _CreateBudgetScreenState createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _amountController = TextEditingController();
  DateTime _startBudgetDate = DateTime.now();
  DateTime _endBudgetDate = DateTime.now().add(Duration(days: 30));
  Map<DateTime, List> _events = {};

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> isOverlapping(String userId, DateTime startBudgetDate, DateTime endBudgetDate) async {
    final url = 'https://backend-bdclpm.onrender.com/api/budgets/';

    final response = await http.post(
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
      debugPrint('Error checking overlap: ${response.body}');
      return false;
    }
  }

  Future<bool> createBudget(String userId, double amount, DateTime startBudgetDate, DateTime endBudgetDate) async {
    final url = 'https://backend-bdclpm.onrender.com/api/budgets';

    final response = await http.post(
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

  Future<void> fetchBudgets() async {
    String userId = await getUserId();
    final url = 'https://backend-bdclpm.onrender.com/api/budgets/$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List budgets = json.decode(response.body);
      Map<DateTime, List> events = {};

      for (var budget in budgets) {
        DateTime start = DateTime.parse(budget['startBudgetDate']);
        DateTime end = DateTime.parse(budget['endBudgetDate']);
        
        for (DateTime date = start; date.isBefore(end.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
          if (!events.containsKey(date)) {
            events[date] = [];
          }
          events[date]?.add('Budget');
        }
      }

      setState(() {
        _events = events;
      });
    } else {
      debugPrint('Failed to load budgets: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(),
            const SizedBox(height: 20),
            _buildDatePicker(
              label: 'Ngày bắt đầu',
              selectedDate: _startBudgetDate,
              onSelectDate: (date) {
                setState(() {
                  _startBudgetDate = date;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildDatePicker(
              label: 'Ngày kết thúc',
              selectedDate: _endBudgetDate,
              onSelectDate: (date) {
                setState(() {
                  _endBudgetDate = date;
                });
              },
            ),
            const SizedBox(height: 30),
            _buildSubmitButton(),
            const SizedBox(height: 30),
            const Text(
              'Lịch ngân sách',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCalendar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Số tiền',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 16),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onSelectDate,
  }) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
      controller: TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(selectedDate),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          onSelectDate(pickedDate);
        }
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 35),
              shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        onPressed: () async {
          String userId = await getUserId();
          if (userId.isEmpty) {
            _showSnackBar('Người dùng chưa đăng nhập.');
            return;
          }

          if (_amountController.text.isEmpty) {
            _showSnackBar('Vui lòng nhập số tiền.');
            return;
          }

          if (_endBudgetDate.isBefore(_startBudgetDate)) {
            _showSnackBar('Ngày kết thúc không thể trước ngày bắt đầu.');
            return;
          }

          bool isOverlap =
              await isOverlapping(userId, _startBudgetDate, _endBudgetDate);
          if (isOverlap) {
            _showSnackBar('Ngân sách đã trùng với khoảng thời gian khác.');
            return;
          }

          bool result = await createBudget(
            userId,
            double.parse(_amountController.text),
            _startBudgetDate,
            _endBudgetDate,
          );

          if (result) {
            _showSnackBar('Tạo ngân sách thành công!');
            fetchBudgets(); 
          } else {
            _showSnackBar('Không thể tạo ngân sách.');
          }
        },
        child: const Text('Tạo ngân sách', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      focusedDay: DateTime.now(),
      eventLoader: (day) {
        return _events[day] ?? [];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          for (var budget in _events.entries) {
            DateTime start = budget.key;
            DateTime end = budget.key.add(Duration(days: 1));
            if (date.isAfter(start.subtract(Duration(days: 1))) &&
                date.isBefore(end.add(Duration(days: 1)))) {
              return Container(
                margin: const EdgeInsets.all(0.5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 121, 161).withOpacity(0.5),
                  shape: BoxShape.rectangle,
                ),
                child: Text('${date.day}', style: TextStyle(color: Colors.black)),
              );
            }
          }
          return null;
        },
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
