import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/home/presentation/widgets/widget_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> expensesData = [];
  List<dynamic> recentOrders = [];
  bool isLoading = true;
  String? userId;
  double totalSpent = 0.0;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
      fetchExpensesData();
      fetchRecentOrders();
    } else {
      setState(() {
        isLoading = false;
      });
      print('Không tìm thấy ID người dùng trong SharedPreferences.');
    }
  }

  Future<void> fetchExpensesData() async {
    final String url =
        'https://backend-bdclpm.onrender.com/api/expenses/expenses-chart/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          expensesData = jsonData['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Không thể lấy dữ liệu chi tiêu.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Lỗi: $e');
    }
  }

  Future<void> fetchRecentOrders() async {
    final String url =
        'https://backend-bdclpm.onrender.com/api/expenses/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recentOrders = data;
          recentOrders.sort((a, b) {
            final dateA = DateTime.parse(a['createdAt']);
            final dateB = DateTime.parse(b['createdAt']);
            return dateB.compareTo(dateA);
          });
          recentOrders = recentOrders.take(4).toList();
          totalSpent = recentOrders.fold(0.0, (sum, item) {
            final amount =
                double.tryParse(item['totalAmount'].toString()) ?? 0.0;
            return sum + amount;
          });
        });
      } else {
        throw Exception('Không thể lấy danh sách giao dịch.');
      }
    } catch (e) {
      print('Lỗi: $e');
    }
  }

  List<PieChartSectionData> _buildChartSections() {
    final double totalAmount = expensesData.fold(
        0.0, (sum, item) => sum + (item['totalAmount'] as num).toDouble());

    return expensesData.map((expense) {
      final double percentage =
          ((expense['totalAmount'] as num).toDouble() / totalAmount) * 100;
      final int index = expensesData.indexOf(expense);

      return PieChartSectionData(
        title: '${percentage.toStringAsFixed(1)}%',
        value: expense['totalAmount'].toDouble(),
        color: Colors.primaries[index % Colors.primaries.length],
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 70,
      );
    }).toList();
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
        return const Color.fromARGB(255, 234, 182, 182);
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

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalSpendingCard(),
                  const SizedBox(height: 20),
                  _buildPieChart(),
                  const SizedBox(height: 20),
                  _buildRecentTransactions(),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalSpendingCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 234, 182, 182),
            Color.fromARGB(255, 122, 180, 216)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 10),
              Text(
                '-${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalSpent)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Icon(Icons.account_balance_wallet,
              size: 50, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiêu theo danh mục',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.black, // Viền đen bên ngoài
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: _buildChartSections(),
              centerSpaceRadius: 50,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Chú thích danh mục
        Wrap(
          spacing: 10,
          children: expensesData.map((expense) {
            int index = expensesData.indexOf(expense);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: Colors.primaries[
                      index % Colors.primaries.length], // Màu sắc tương ứng
                ),
                const SizedBox(width: 5),
                Text(
                  expense['categoryName'], // Tên danh mục
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giao dịch gần đây',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentOrders.length,
          itemBuilder: (context, index) {
            final order = recentOrders[index];
            final formattedDate = DateFormat('dd/MM/yyyy')
                .format(DateTime.parse(order['createdAt']));

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      getCategoryColor(order['categoryId']['icon'] ?? ''),
                  child: Icon(
                      getIconFromString(order['categoryId']['icon'] ?? '')),
                ),
                title: Text(
                  order['storeName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text(
                  order['description'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(order['totalAmount'])}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 181, 41, 41),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(formattedDate, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
