import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String userId = '';
  double totalSpent = 0.0; // Tổng số tiền đã chi tiêu

  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  Future<void> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
      fetchOrderHistory(storedUserId);
    } else {
      setState(() {
        isLoading = false;
      });
      print("User ID not found in SharedPreferences.");
    }
  }

  Future<void> fetchOrderHistory(String userId) async {
    final url = Uri.parse('http://192.168.1.213:4000/api/expenses/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orders = data;
          isLoading = false;

          // Tính tổng tiền đã chi tiêu
          totalSpent = orders.fold(0.0, (sum, item) {
            final amount = double.tryParse(item['totalAmount'].toString()) ?? 0.0;
            return sum + amount;
          });
        });
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching orders: $e");
    }
  }

  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.fastfood;
      case 'devices':
        return Icons.devices;
      case 'service':
        return Icons.design_services;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'style':
        return Icons.style;
      case 'Khác':
        return Icons.help_outline;
      default:
        return Icons.help;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Giao Dịch'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Phần hiển thị tổng tiền chi tiêu
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.red],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(16),
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
                  child: orders.isEmpty
                      ? const Center(
                          child: Text(
                            'Không có giao dịch nào.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final formattedDate = DateFormat('dd/MM/yyyy').format(
                              DateTime.parse(order['date']),
                            );

                            final category = order['categoryId'];
                            final iconName = category != null ? category['icon'] : 'default';
                            final categoryName =
                                category != null ? category['name'] : 'Unknown';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: getCategoryColor(iconName),
                                    radius: 30,
                                    child: Icon(
                                      getIconFromString(iconName),
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  title: Text(
                                    order['storeName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        categoryName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        order['description'],
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${order['totalAmount'] > 0 ? '+' : ''}${order['totalAmount']} VND',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: order['totalAmount'] > 0
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
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
