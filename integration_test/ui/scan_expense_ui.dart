import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan_expense_page.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/scan_expense_controller.dart';
import '../../test/mocks/mocks.mocks.dart';
import 'package:intl/intl.dart';
void main() {
  late MockScanExpenseController mockController;

  setUp(() {
    mockController = MockScanExpenseController();
    when(mockController.formatCurrency(any)).thenAnswer((invocation) {
      final amount = invocation.positionalArguments[0] as double;
      return NumberFormat("#,##0", "vi_VN").format(amount);
    });
  });

  // Helper function to create widget
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ScanExpensePage(
          storeName: 'quan an thien tan',
          totalAmount: 100.000,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '2025-03-17',
          categoryId: '678d18f502455271e95277b4',
          categoryname:'Thực phẩm',
          currency: 'VND',
        ),
      ),
    );
  }

  testWidgets('Hiển thị tất cả các thành phần UI ban đầu', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Thêm chi tiêu'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Bạn muốn nhập chi tiêu như thế nào?'), findsOneWidget);
    expect(find.text('Nhập thủ công'), findsOneWidget);
    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Quét pdf/excel'), findsOneWidget);
    expect(find.text('Nhận dạng giọng nói'), findsOneWidget);
    expect(find.text('Tên cửa hàng'), findsOneWidget);
    expect(find.text('Số tiền'), findsOneWidget);
    expect(find.text('Ngày'), findsOneWidget);
    expect(find.text('Mô tả'), findsOneWidget);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('Danh mục'), findsOneWidget);
    expect(find.text('Loại tiền tệ'), findsOneWidget);

    expect(find.text('Lưu chi tiêu'), findsOneWidget);
  });
}