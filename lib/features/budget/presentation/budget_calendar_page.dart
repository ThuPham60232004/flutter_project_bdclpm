import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/budget/controllers/budget_calendar_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class BudgetCalendarPage extends StatefulWidget {
  final Map<String, dynamic> budget;

  const BudgetCalendarPage({super.key, required this.budget});

  @override
  _BudgetCalendarPageState createState() => _BudgetCalendarPageState();
}

class _BudgetCalendarPageState extends State<BudgetCalendarPage> {
  final BudgetCalendarController _controller = BudgetCalendarController();
  String _message = '';
  bool _isOverBudget = false;
  double _totalExpenses = 0.0;
  List<dynamic> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    final userId = await _controller.getUserId();
    final String budgetId = widget.budget['_id'];

    if (userId == null) {
      setState(() {
        _message = 'Không tìm thấy userId!';
      });
      return;
    }

    try {
      final data = await _controller.checkBudgetLimit(userId, budgetId);

      final now = DateTime.now();
      final startBudgetDate = DateTime.parse(data['startBudgetDate']);
      final endBudgetDate = DateTime.parse(data['endBudgetDate']);

      setState(() {
        _message = data['message'] ?? 'Không có thông báo';
        _isOverBudget = data['status'] == 'exceeded';
        _totalExpenses = (data['totalExpenses'] ?? 0).toDouble();
        _expenses = data['expenses'] ?? [];
      });

      if (now.isBefore(startBudgetDate) || now.isAfter(endBudgetDate)) {
        setState(() {
          _message = 'Ngân sách này không còn hiệu lực!';
          _isOverBudget = false;
          _totalExpenses = 0.0;
          _expenses = [];
        });
      }
    } catch (error, stackTrace) {
      debugPrint('❌ Lỗi khi gọi API: $error');
      debugPrint('🔍 StackTrace: $stackTrace');
      setState(() {
        _message = 'Lỗi khi tải dữ liệu: $error';
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
        title: const Text('Cảnh báo ngân sách'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetInfo(amount, startBudgetDate, endBudgetDate),
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
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetInfo(double amount, DateTime start, DateTime end) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngân sách: ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(amount)}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Thời gian: ${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCalendar(DateTime startDate, DateTime endDate) {
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      focusedDay: DateTime.now(),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green.withOpacity(0.7),
          shape: BoxShape.rectangle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              date.isBefore(endDate.add(const Duration(days: 1)))) {
            return Container(
              margin: const EdgeInsets.all(0.1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
                shape: BoxShape.rectangle,
              ),
              child: Text('${date.day}', style: const TextStyle(color: Colors.black)),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildExpenseList() {
    if (_expenses.isEmpty) {
      return const Center(
        child: Text(
          'Không có khoản chi tiêu nào.',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Danh sách chi tiêu:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._expenses.map((expense) {
          final expenseDate = DateTime.parse(expense['date']);
          return ListTile(
            title: Text('Chi tiêu: ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(expense['totalAmount'])}'),
            subtitle: Text('Ngày: ${DateFormat('dd/MM/yyyy').format(expenseDate)}'),
            trailing: const Icon(Icons.money),
          );
        }).toList(),
      ],
    );
  }
}
