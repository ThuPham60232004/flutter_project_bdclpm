import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ListCategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ListCategoryPage(
      {required this.categoryId, required this.categoryName});

  @override
  _ListCategoryPageState createState() => _ListCategoryPageState();
}

class _ListCategoryPageState extends State<ListCategoryPage> {
  List<dynamic> expenses = [];
  bool isLoading = true;
  double totalSpent = 0.0;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse(
          'https://backend-bdclpm.onrender.com/api/expenses/category/${widget.categoryId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          expenses = data;
          totalSpent = calculateTotalSpent(data);
          isLoading = false;
        });
      } else {
        throw Exception('Không thể tải danh sách chi tiêu');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  double calculateTotalSpent(List<dynamic> expenses) {
    return expenses.fold(
        0.0, (sum, expense) => sum + (expense['totalAmount'] ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Chi tiêu: ${widget.categoryName}',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 134, 176, 250),
                          const Color.fromARGB(255, 176, 138, 242)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tổng chi tiêu',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(height: 8),
                            Text(
                                '-${NumberFormat.currency(locale: 'vi', symbol: '₫').format(totalSpent)}',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                        Icon(Icons.account_balance_wallet,
                            size: 40, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: expenses.isEmpty
                      ? Center(child: Text('Không có chi tiêu nào.'))
                      : Center(
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              return ExpenseCard(expense: expense);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> expense;

  const ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final categoryIcon = expense['categoryId']['icon'] ?? 'category';
    final storeName = expense['storeName'] ?? 'Không rõ cửa hàng';
    final totalAmount = expense['totalAmount'] ?? 0;
    final date = expense['date'] ?? '';

    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: getCategoryColor(categoryIcon),
          child: Icon(
            _getIconData(categoryIcon),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          storeName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          'Ngày: $formattedDate',
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 150, 208, 246),
                    Color.fromARGB(255, 187, 181, 255)
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalAmount)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.fastfood;
      case 'devices':
        return Icons.devices;
      case 'service':
        return Icons.build;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'style':
        return Icons.style;
      default:
        return Icons.category;
    }
  }

  Color getCategoryColor(String iconName) {
    switch (iconName) {
      case 'food':
        return const Color.fromARGB(255, 163, 219, 235);
      case 'devices':
        return const Color.fromARGB(255, 215, 187, 251);
      case 'service':
        return Colors.yellow.shade100;
      case 'local_shipping':
        return Colors.red.shade100;
      case 'style':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade300;
    }
  }
}
