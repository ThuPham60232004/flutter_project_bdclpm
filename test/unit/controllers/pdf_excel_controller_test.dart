import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/pdf_excel_controller.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/pdf_excel.dart';

class MockPdfExcelController extends Mock implements PdfExcelController {}

void main() {
  late MockPdfExcelController mockController;

  setUp(() {
    mockController = MockPdfExcelController();
  });

  testWidgets('Trang PdfExcelPage hiển thị dữ liệu ban đầu đúng', (WidgetTester tester) async {
    when(mockController.fetchCategories()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfExcelController>.value(
          value: mockController,
          child: PdfExcelPage(),
        ),
      ));

    await tester.pumpAndSettle();

    expect(find.text('Xử lý PDF/Excel'), findsOneWidget);
    expect(find.text('Tên cửa hàng'), findsOneWidget);
    expect(find.text('Số tiền'), findsOneWidget);
    expect(find.text('Ngày'), findsOneWidget);
    expect(find.text('Mô tả'), findsOneWidget);
    expect(find.text('Chọn danh mục'), findsOneWidget);
  });

testWidgets('Trang PdfExcelPage chọn phương thức quét đúng', (WidgetTester tester) async {
  // Mock controller để trả về dữ liệu giả cho fetchCategories
  when(mockController.fetchCategories()).thenAnswer((_) async => ['Category 1', 'Category 2']);

  await tester.pumpWidget(MaterialApp(
    home: ChangeNotifierProvider<PdfExcelController>.value(
      value: mockController,
      child: PdfExcelPage(),
    ),
  ));

  await tester.pumpAndSettle(); // Đảm bảo mọi tác vụ bất đồng bộ đã hoàn thành

  // Kiểm tra xem phương thức quét có được hiển thị đúng không
  expect(find.text('Quét PDF/Excel'), findsOneWidget);
});


  testWidgets('Trang PdfExcelPage xử lý tệp PDF đúng', (WidgetTester tester) async {
    when(mockController.pickPdfOrExcelFile()).thenAnswer((_) async => {});

    await tester.pumpWidget(MaterialApp(
      home: PdfExcelPage(),
    ));

    await tester.tap(find.text('Chọn Tệp'));
    await tester.pump();

    verify(mockController.pickPdfOrExcelFile()).called(1);
  });

  testWidgets('Trang PdfExcelPage hiển thị snackbar lỗi khi xử lý PDF thất bại', (WidgetTester tester) async {
    when(mockController.pickPdfOrExcelFile()).thenThrow(Exception('Test Error'));

    await tester.pumpWidget(MaterialApp(
      home: PdfExcelPage(),
    ));

    await tester.tap(find.text('Chọn Tệp'));
    await tester.pump();

    expect(find.text('Lỗi: Test Error'), findsOneWidget);
  });

  testWidgets('Trang PdfExcelPage lưu chi tiêu đúng', (WidgetTester tester) async {
    when(mockController.saveExpense()).thenAnswer((_) async => {});

    await tester.pumpWidget(MaterialApp(
      home: PdfExcelPage(),
    ));

    await tester.tap(find.text('Lưu chi tiêu'));
    await tester.pump();

    verify(mockController.saveExpense()).called(1);
  });

  testWidgets('Trang PdfExcelPage hiển thị snackbar lỗi khi lưu chi tiêu thất bại', (WidgetTester tester) async {
    when(mockController.saveExpense()).thenThrow(Exception('Test Error'));

    await tester.pumpWidget(MaterialApp(
      home: PdfExcelPage(),
    ));

    await tester.tap(find.text('Lưu chi tiêu'));
    await tester.pump();

    expect(find.text('Đã xảy ra lỗi: Test Error'), findsOneWidget);
  });
}
