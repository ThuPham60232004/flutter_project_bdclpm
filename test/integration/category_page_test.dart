import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/listcategory/presentation/category_page.dart';

void main() {
  group('Category UI Test', () {
    testWidgets('Hiển thị tiêu đề danh mục', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CategoryPage()));

      expect(find.text('Danh mục'), findsOneWidget);
    });

    testWidgets('Hiển thị CircularProgressIndicator khi đang tải',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CategoryPage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Hiển thị lưới danh mục', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CategoryPage()));
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
