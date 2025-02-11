import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class IncomeHistoryScreen extends StatefulWidget {
  @override
  _IncomeHistoryScreenState createState() => _IncomeHistoryScreenState();
}

class _IncomeHistoryScreenState extends State<IncomeHistoryScreen> {
  List incomes = [];
  bool isLoading = true;
  double totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    fetchIncomes();
  }

  Future<void> fetchIncomes() async {
    final response = await http
        .get(Uri.parse('https://backend-bdclpm.onrender.com/api/incomes/'));
    if (response.statusCode == 200) {
      setState(() {
        incomes = json.decode(response.body);
        totalIncome = incomes.fold(
            0.0, (sum, item) => sum + (item['amount']?.toDouble() ?? 0.0));
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteIncome(String id) async {
    final response = await http.delete(
        Uri.parse('https://backend-bdclpm.onrender.com/api/incomes/$id'));
    if (response.statusCode == 200) {
      setState(() {
        incomes.removeWhere((income) => income['_id'] == id);
        totalIncome = incomes.fold(
            0.0, (sum, item) => sum + (item['amount']?.toDouble() ?? 0.0));
      });
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
                            onPressed: () => deleteIncome(income['_id']),
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
