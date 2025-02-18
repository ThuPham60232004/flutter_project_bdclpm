import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/scan_expense_controller.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan_expense_page.dart';
import '../../mocks/mocks.mocks.dart';
class MockScanExpenseController extends Mock implements ScanExpenseController {}

void main() {
  late MockScanExpenseController mockController;

  setUp(() {
    mockController = MockScanExpenseController();
  });

  testWidgets('Hiển thị dữ liệu ban đầu đúng', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ScanExpensePage(
        storeName: 'Cửa hàng A',
        totalAmount: 100,
        description: 'Mô tả test',
        date: '01/01/2023',
        categoryId: '1',
        categoryname: 'Danh mục A',
      ),
    ));

    await tester.pumpAndSettle(); 
    debugDumpApp(); 
    expect(find.text('Cửa hàng A'), findsOneWidget);
    expect(
        find.textContaining('100'), findsOneWidget);
    expect(find.text('01/01/2023'), findsOneWidget);
    expect(find.text('Mô tả test'), findsOneWidget);
    expect(find.text('Danh mục A'), findsOneWidget);
  });

  testWidgets('Chọn phương thức quét hóa đơn đúng',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ScanExpensePage(
        storeName: 'Cửa hàng A',
        totalAmount: 100.0,
        description: 'Mô tả test',
        date: '01/01/2023',
        categoryId: '1',
        categoryname: 'Danh mục A',
      ),
    ));

    await tester.tap(find.text('Quét hóa đơn'));
    await tester.pump();

    expect(find.text('Quét hóa đơn'), findsOneWidget);
  });

  testWidgets('Định dạng ngày tháng đúng', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ScanExpensePage(
        storeName: 'Cửa hàng A',
        totalAmount: 100.0,
        description: 'Mô tả test',
        date: '01/01/2023',
        categoryId: '1',
        categoryname: 'Danh mục A',
      ),
    ));

    final dateField = find.byType(TextFormField).at(2);
    await tester.enterText(dateField, '01012023');
    await tester.pumpAndSettle();

    final textField = tester.widget<TextFormField>(dateField);
    expect(textField.controller!.text, '01/01/2023');
  });
  // Gọi hàm createExpense khi nhấn Lưu chi tiêu
  //Hiển thị thông báo lỗi khi tạo chi tiêu thất bại
}
