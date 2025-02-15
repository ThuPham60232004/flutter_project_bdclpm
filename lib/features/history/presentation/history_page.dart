import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/history/controllers/history_controller.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController _controller = HistoryController();
  List<dynamic> orders = [];
  bool isLoading = true;
  double totalSpent = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await _controller.fetchUserId();
    if (userId != null) {
      final data = await _controller.fetchOrderHistory(userId);
      setState(() {
        orders = data;
        totalSpent = orders.fold(0.0, (sum, item) =>
            sum + (double.tryParse(item['totalAmount'].toString()) ?? 0.0));
      });
    }
    setState(() => isLoading = false);
  }

  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'food': return Icons.fastfood;
      case 'devices': return Icons.devices;
      case 'service': return Icons.design_services;
      case 'local_shipping': return Icons.local_shipping;
      case 'style': return Icons.style;
      default: return Icons.help;
    }
  }

  Color getCategoryColor(String iconName) {
    switch (iconName) {
      case 'food': return Colors.green.shade300;
      case 'devices': return Colors.blue.shade300;
      case 'service': return Colors.orange.shade300;
      case 'local_shipping': return Colors.red.shade300;
      case 'style': return Colors.purple.shade300;
      default: return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Giao Dịch', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('Không có giao dịch nào.', style: TextStyle(fontSize: 16, color: Colors.black54)))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(order['date']));
                    final category = order['categoryId'];
                    final iconName = category != null ? category['icon'] : 'default';
                    final categoryName = category != null ? category['name'] : 'Unknown';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: getCategoryColor(iconName),
                            radius: 28,
                            child: Icon(getIconFromString(iconName), color: Colors.white, size: 26),
                          ),
                          title: Text(order['storeName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(categoryName, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                              Text(order['description'], style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
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
                                  color: order['totalAmount'] > 0 ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                              Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
