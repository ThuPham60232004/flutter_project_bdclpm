import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan_expense_page.dart';

void main() {
  testWidgets('Debug số tiền hiển thị', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScanExpensePage(
          storeName: "Siêu thị ABC",
          totalAmount: 120000,
          description: "Mua thực phẩm",
          date: "10/03/2025",
          categoryId: "123",
          categoryname: "Ăn uống",
          currency: "VND",
        ),
      ),
    );

    await tester.pumpAndSettle();
    tester.allWidgets.whereType<Text>().forEach((widget) {
      print("Text widget: ${widget.data}");
    });
  });

  testWidgets('Hiển thị đúng các phương thức nhập chi tiêu',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScanExpensePage(
          storeName: "Siêu thị ABC",
          totalAmount: 120000,
          description: "Mua thực phẩm",
          date: "10/03/2025",
          categoryId: "123",
          categoryname: "Ăn uống",
          currency: "VND",
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Nhập thủ công"), findsOneWidget);
    expect(find.text("Quét hóa đơn"), findsOneWidget);
    expect(find.text("Quét pdf/excel"), findsOneWidget);
    expect(find.text("Nhận dạng giọng nói"), findsOneWidget);
  });

  testWidgets('Thay đổi loại tiền tệ sang USD', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScanExpensePage(
          storeName: "Siêu thị ABC",
          totalAmount: 120000,
          description: "Mua thực phẩm",
          date: "10/03/2025",
          categoryId: "123",
          categoryname: "Ăn uống",
          currency: "VND",
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text("USD"), findsOneWidget);
  });

  testWidgets('Nút Lưu chi tiêu hiển thị đúng', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScanExpensePage(
          storeName: "Siêu thị ABC",
          totalAmount: 120000,
          description: "Mua thực phẩm",
          date: "10/03/2025",
          categoryId: "123",
          categoryname: "Ăn uống",
          currency: "VND",
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Lưu chi tiêu"), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
