import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/listcategory/controllers.dart/list_category_controller.dart';

class ListCategoryPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const ListCategoryPage({required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = ListCategoryController();
        controller.fetchExpenses(categoryId);
        return controller;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('Chi tiêu: $categoryName',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Consumer<ListCategoryController>(
          builder: (context, controller, child) {
            return controller.isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTotalSpentCard(controller.totalSpent),
                      Expanded(
                        child: controller.expenses.isEmpty
                            ? Center(child: Text('Không có chi tiêu nào.'))
                            : ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: controller.expenses.length,
                                itemBuilder: (context, index) {
                                  return ExpenseCard(expense: controller.expenses[index]);
                                },
                              ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildTotalSpentCard(double totalSpent) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF86B0FA), Color(0xFFB08AF2)],
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 8),
                Text('-${NumberFormat.currency(locale: 'vi', symbol: '₫').format(totalSpent)}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            Icon(Icons.account_balance_wallet, size: 40, color: Colors.white),
          ],
        ),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey,
          child: Icon(Icons.category, color: Colors.white, size: 24),
        ),
        title: Text(
          storeName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text('Ngày: $formattedDate', style: const TextStyle(color: Colors.black54, fontSize: 14)),
        trailing: Text(
          '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalAmount)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}