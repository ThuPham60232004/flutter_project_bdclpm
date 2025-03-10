import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project_bdclpm/features/listcategory/controllers.dart/category_wise_expenses_controller.dart';
import 'package:flutter_project_bdclpm/features/listcategory/presentation/expenses_category.dart';
import 'package:fl_chart/fl_chart.dart';

class MockCategoryWiseExpensesController extends ChangeNotifier
    implements CategoryWiseExpensesController {
  bool isLoading = false;
  String? userId = 'test_user';
  List<dynamic> expensesData = [
    {'categoryName': 'Ăn uống', 'totalAmount': 500.0},
    {'categoryName': 'Giải trí', 'totalAmount': 300.0},
  ];

  @override
  Future<void> loadUserId() async {}

  @override
  Future<void> fetchExpensesData() async {}
}

void main() {
  testWidgets('CategoryWiseExpensesPage Integration Test',
      (WidgetTester tester) async {
    final mockController = MockCategoryWiseExpensesController();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<CategoryWiseExpensesController>.value(
          value: mockController,
          child: const CategoryWiseExpensesPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Biểu đồ chi tiêu theo danh mục'), findsOneWidget);
    expect(find.text('Chi tiêu theo danh mục'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('Danh sách chi tiêu:'), findsOneWidget);
    expect(find.text('Ăn uống'), findsOneWidget);
    expect(find.text('Giải trí'), findsOneWidget);
    expect(find.text('Số tiền: 500.0'), findsOneWidget);
    expect(find.text('Số tiền: 300.0'), findsOneWidget);
  });
}
