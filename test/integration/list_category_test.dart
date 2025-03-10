import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/listcategory/presentation/list_category.dart';

void main() {
  group('ListCategoryPage UI Test', () {
    testWidgets('Hiển thị tiêu đề và tổng chi tiêu',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ListCategoryPage(categoryId: '1', categoryName: 'Ăn uống')));
      await tester.pumpAndSettle();

      expect(find.text('Chi tiêu: Ăn uống'), findsOneWidget);
      expect(find.text('Tổng chi tiêu'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('Hiển thị danh sách chi tiêu rỗng',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ListCategoryPage(categoryId: '1', categoryName: 'Giải trí')));
      await tester.pumpAndSettle();
      expect(find.text('Không có chi tiêu nào.'), findsOneWidget);
    });
  });
}
