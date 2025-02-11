import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryWiseExpensesPage extends StatefulWidget {
  const CategoryWiseExpensesPage({Key? key}) : super(key: key);

  @override
  _CategoryWiseExpensesPageState createState() =>
      _CategoryWiseExpensesPageState();
}

class _CategoryWiseExpensesPageState extends State<CategoryWiseExpensesPage> {
  List<dynamic> expensesData = [];
  bool isLoading = true;
  String? userId;

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
    } else {
      setState(() {
        isLoading = false;
      });
      print('Không tìm thấy userId trong SharedPreferences.');
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
        throw Exception('Failed to fetch expenses');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  List<PieChartSectionData> _buildChartSections() {
    final double totalAmount = expensesData.fold(
      0.0,
      (sum, item) => sum + (item['totalAmount'] as num).toDouble(),
    );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biểu đồ chi tiêu theo danh mục'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userId == null
              ? const Center(
                  child: Text(
                    'Không tìm thấy thông tin người dùng.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : expensesData.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có dữ liệu chi tiêu',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Chi tiêu theo danh mục',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 300, // Đặt chiều cao cố định cho biểu đồ
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: PieChart(
                                    PieChartData(
                                      sections: _buildChartSections(),
                                      centerSpaceRadius: 50,
                                      sectionsSpace: 2,
                                      borderData: FlBorderData(show: false),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Danh sách chi tiêu:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: expensesData.length,
                              itemBuilder: (context, index) {
                                final expense = expensesData[index];
                                return Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.primaries[
                                              index % Colors.primaries.length]
                                          .withOpacity(0.8),
                                    ),
                                    title: Text(
                                      expense['categoryName'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Số tiền: ${expense['totalAmount']}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
