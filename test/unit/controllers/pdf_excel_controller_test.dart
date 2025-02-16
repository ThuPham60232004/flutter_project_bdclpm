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

  // testWidgets('PdfExcelPage displays correct initial data', (WidgetTester tester) async {
  //   await tester.pumpWidget(MaterialApp(
  //     home: PdfExcelPage(),
  //   ));

  //   expect(find.text('Xử lý PDF/Excel'), findsOneWidget);
  //   expect(find.text('Tên cửa hàng'), findsOneWidget);
  //   expect(find.text('Số tiền'), findsOneWidget);
  //   expect(find.text('Ngày'), findsOneWidget);
  //   expect(find.text('Mô tả'), findsOneWidget);
  //   expect(find.text('Chọn danh mục'), findsOneWidget);
  // });

  // testWidgets('PdfExcelPage selects scan method correctly', (WidgetTester tester) async {
  //   await tester.pumpWidget(MaterialApp(
  //     home: PdfExcelPage(),
  //   ));

  //   await tester.tap(find.text('Quét PDF/Excel'));
  //   await tester.pump();

  //   expect(find.text('Quét PDF/Excel'), findsOneWidget);
  // });

  // testWidgets('PdfExcelPage processes PDF file correctly', (WidgetTester tester) async {
  //   when(mockController.pickPdfOrExcelFile()).thenAnswer((_) async => {});

  //   await tester.pumpWidget(MaterialApp(
  //     home: PdfExcelPage(),
  //   ));

  //   await tester.tap(find.text('Chọn Tệp'));
  //   await tester.pump();

  //   verify(mockController.pickPdfOrExcelFile()).called(1);
  // });

  // testWidgets('PdfExcelPage shows error snackbar on PDF processing failure', (WidgetTester tester) async {
  //   when(mockController.pickPdfOrExcelFile()).thenThrow(Exception('Test Error'));

  //   await tester.pumpWidget(MaterialApp(
  //     home: PdfExcelPage(),
  //   ));

  //   await tester.tap(find.text('Chọn Tệp'));
  //   await tester.pump();

  //   expect(find.text('Lỗi: Test Error'), findsOneWidget);
  // });

  // testWidgets('PdfExcelPage saves expense correctly', (WidgetTester tester) async {
  //   when(mockController.saveExpense()).thenAnswer((_) async => {});

  //   await tester.pumpWidget(MaterialApp(
  //     home: PdfExcelPage(),
  //   ));

  //   await tester.tap(find.text('Lưu chi tiêu'));
  //   await tester.pump();

  //   verify(mockController.saveExpense()).called(1);
  // });

  // testWidgets('PdfExcelPage shows error snackbar on save expense failure', (WidgetTester tester) async {
  //   when(mockController.saveExpense()).thenThrow(Exception('Test Error'));

  //   await tester.pumpWidget(MaterialApp(
  //     home: PdfExcelPage(),
  //   ));

  //   await tester.tap(find.text('Lưu chi tiêu'));
  //   await tester.pump();

  //   expect(find.text('Đã xảy ra lỗi: Test Error'), findsOneWidget);
  // });
}
