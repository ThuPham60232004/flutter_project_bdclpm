import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/budget/presentation/budget_calendar_page.dart';
import 'package:flutter_project_bdclpm/features/budget/controllers/budget_controller.dart';

class BudgetListPage extends StatefulWidget {
  @override
  BudgetListPageState createState() => BudgetListPageState();
}

class BudgetListPageState extends State<BudgetListPage> {
  final BudgetController _budgetController = BudgetController();
  List<dynamic> budgets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      final data = await _budgetController.fetchBudgets();
      setState(() {
        budgets = data;
        isLoading = false;
      });
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BudgetCalendarPage(budget: budget),
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
      onTap: onTap,
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
