import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project_bdclpm/features/listcategory/controllers.dart/category_wise_expenses_controller.dart';

class CategoryWiseExpensesPage extends StatefulWidget {
  const CategoryWiseExpensesPage({Key? key}) : super(key: key);

  @override
  _CategoryWiseExpensesPageState createState() =>
      _CategoryWiseExpensesPageState();
}

class _CategoryWiseExpensesPageState extends State<CategoryWiseExpensesPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<CategoryWiseExpensesController>(context, listen: false)
        .loadUserId();
  }

  List<PieChartSectionData> _buildChartSections(List<dynamic> expensesData) {
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
    final controller = Provider.of<CategoryWiseExpensesController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biểu đồ chi tiêu theo danh mục'),
        backgroundColor: Colors.white,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.userId == null
              ? const Center(
                  child: Text(
                    'Không tìm thấy thông tin người dùng.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : controller.expensesData.isEmpty
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
                              height: 300,
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: PieChart(
                                    PieChartData(
                                      sections:
                                          _buildChartSections(controller.expensesData),
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
                              itemCount: controller.expensesData.length,
                              itemBuilder: (context, index) {
                                final expense = controller.expensesData[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 5),
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
                                      style: const TextStyle(color: Colors.grey),
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
