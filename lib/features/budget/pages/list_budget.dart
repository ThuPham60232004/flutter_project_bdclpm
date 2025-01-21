import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/budget/pages/budget_calendar_page.dart';  

class BudgetListPage extends StatefulWidget {
  @override
  _BudgetListPageState createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  List<dynamic> budgets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    try {
      final response = await http.get(Uri.parse('https://backend-bdclpm.onrender.com/api/budgets/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          budgets = data;
          isLoading = false;
        });
      } else {
        throw Exception('Không thể tải danh sách ngân sách');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Lỗi tải ngân sách: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Ngân sách'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : budgets.isEmpty
              ? const Center(child: Text('Không có ngân sách nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    return BudgetCard(
                      budget: budget,
                      onTap: () {
                        // Khi bấm vào ngân sách, điều hướng đến trang lịch ngân sách
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BudgetCalendarPage(budget: budget),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class BudgetCard extends StatelessWidget {
  final Map<String, dynamic> budget;
  final VoidCallback onTap;

  const BudgetCard({required this.budget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double amount = (budget['amount'] is int)
        ? (budget['amount'] as int).toDouble() 
        : budget['amount']?.toDouble() ?? 0.0;

    final startBudgetDate = DateTime.parse(budget['startBudgetDate']);
    final endBudgetDate = DateTime.parse(budget['endBudgetDate']);

    return GestureDetector(
      onTap: onTap,  // Khi người dùng bấm vào ngân sách
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: Colors.green.shade300,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngân sách ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(amount)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thời gian: ${DateFormat('dd/MM/yyyy').format(startBudgetDate)} - ${DateFormat('dd/MM/yyyy').format(endBudgetDate)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
