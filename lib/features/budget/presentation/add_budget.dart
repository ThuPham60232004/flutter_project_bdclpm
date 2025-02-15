import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_project_bdclpm/features/budget/controllers/create_budget_controller.dart';

class CreateBudgetScreen extends StatefulWidget {
  @override
  _CreateBudgetScreenState createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _amountController = TextEditingController();
  DateTime _startBudgetDate = DateTime.now();
  DateTime _endBudgetDate = DateTime.now().add(Duration(days: 30));
  final CreateBudgetController _controller = CreateBudgetController();
  Map<DateTime, List> _events = {};

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    Map<DateTime, List> events = await _controller.fetchBudgets();
    setState(() {
      _events = events;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleSubmit() async {
    String userId = await _controller.getUserId();
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
        await _controller.isOverlapping(userId, _startBudgetDate, _endBudgetDate);
    if (isOverlap) {
      _showSnackBar('Ngân sách đã trùng với khoảng thời gian khác.');
      return;
    }

    bool result = await _controller.createBudget(
      userId,
      double.parse(_amountController.text),
      _startBudgetDate,
      _endBudgetDate,
    );

    if (result) {
      _showSnackBar('Tạo ngân sách thành công!');
      _loadBudgets();
    } else {
      _showSnackBar('Không thể tạo ngân sách.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ngân sách'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(),
            const SizedBox(height: 20),
            _buildDatePicker('Ngày bắt đầu', _startBudgetDate, (date) {
              setState(() => _startBudgetDate = date);
            }),
            const SizedBox(height: 20),
            _buildDatePicker('Ngày kết thúc', _endBudgetDate, (date) {
              setState(() => _endBudgetDate = date);
            }),
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

  Widget _buildDatePicker(
      String label, DateTime selectedDate, Function(DateTime) onSelectDate) {
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _handleSubmit,
        child: const Text('Tạo ngân sách', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      focusedDay: DateTime.now(),
      eventLoader: (day) => _events[day] ?? [],
    );
  }
}
