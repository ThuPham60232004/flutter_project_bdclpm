import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/history/controllers/income_history_controller.dart';

class IncomeHistoryScreen extends StatefulWidget {
  @override
  _IncomeHistoryScreenState createState() => _IncomeHistoryScreenState();
}

class _IncomeHistoryScreenState extends State<IncomeHistoryScreen> {
  final IncomeController _controller = IncomeController();
  List<dynamic> incomes = [];
  bool isLoading = true;
  double totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    try {
      final fetchedIncomes = await _controller.fetchIncomes();
      setState(() {
        incomes = fetchedIncomes;
        totalIncome = _controller.calculateTotalIncome(incomes);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load incomes: $e')),
      );
    }
  }

  Future<void> _deleteIncome(String id) async {
    try {
      await _controller.deleteIncome(id);
      setState(() {
        incomes.removeWhere((income) => income['_id'] == id);
        totalIncome = _controller.calculateTotalIncome(incomes);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete income: $e')),
      );
    }
  }

  String formatCurrency(num amount) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return currencyFormatter.format(amount.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử thu nhập'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 76, 175, 160),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                'Tổng thu nhập: ${formatCurrency(totalIncome)}',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: incomes.length,
                    itemBuilder: (context, index) {
                      var income = incomes[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(15),
                          leading: Icon(Icons.attach_money,
                              color: Colors.green, size: 30),
                          title: Text(
                            formatCurrency(income['amount']?.toDouble() ?? 0.0),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(income['description'] ?? 'Không có mô tả',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600])),
                              SizedBox(height: 5),
                              Text(
                                income['date'].toString().split('T')[0],
                                style: TextStyle(
                                    fontSize: 14, color: Colors.blueAccent),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete,
                                color: const Color.fromARGB(255, 0, 0, 0)),
                            onPressed: () => _deleteIncome(income['_id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
