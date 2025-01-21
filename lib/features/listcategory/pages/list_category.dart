import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ListCategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ListCategoryPage({required this.categoryId, required this.categoryName});

  @override
  _ListCategoryPageState createState() => _ListCategoryPageState();
}

class _ListCategoryPageState extends State<ListCategoryPage> {
  List<dynamic> expenses = [];
  bool isLoading = true;
  double totalSpent = 0.0; // Biến lưu tổng tiền chi tiêu

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
          totalSpent = calculateTotalSpent(data); // Tính tổng tiền
          isLoading = false;
        });
      } else {
        throw Exception('Không thể tải danh sách chi tiêu');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Lỗi tải chi tiêu: $error');
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
        title: Text('Chi tiêu: ${widget.categoryName}'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 155, 220, 255),
                          Color.fromARGB(255, 200, 248, 154)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
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
                            const Text(
                              'Tổng chi tiêu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '-${NumberFormat.currency(locale: 'vi', symbol: '₫').format(totalSpent)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: expenses.isEmpty
                      ? Center(child: Text('Không có chi tiêu nào.'))
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return ExpenseCard(expense: expense);
                          },
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
    final category = expense['categoryId'] ?? {};
    final categoryName = category['name'] ?? 'Không rõ';
    final categoryIcon = category['icon'] ?? 'category';
    final storeName = expense['storeName'] ?? 'Không rõ cửa hàng';
    final totalAmount = expense['totalAmount'] ?? 0;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: getCategoryColor(categoryIcon),
              child: Icon(
                _getIconData(categoryIcon),
                color: Colors.black,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Giới hạn độ dài tên cửa hàng và thêm dấu "..."
                  Text(
                    storeName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Giới hạn tên cửa hàng trên 1 dòng
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Danh mục: $categoryName',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${NumberFormat.currency(locale: 'vi', symbol: '₫').format(totalAmount)}',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  expense['date'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
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
        return Colors.green.shade100;
      case 'devices':
        return Colors.blue.shade100;
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
