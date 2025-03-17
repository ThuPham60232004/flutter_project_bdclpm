import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan.dart';

void main() {
  group(' Scan Test', () {
    testWidgets('Hiển thị tiêu đề trang', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ScanPage(title: 'Scan Page')));

      expect(find.text('Scan Page'), findsOneWidget);
    });

    testWidgets('Hiển thị nút chọn ảnh', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanPage()));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('Hiển thị thông báo khi chưa chọn ảnh',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanPage()));

      expect(find.text('No image selected.'), findsOneWidget);
    });

    testWidgets('Nút upload luôn hiển thị', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ScanPage()));
      expect(find.text('Upload to Cloud'), findsOneWidget);
    });

    testWidgets('Hiển thị loader khi đang tải', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanPage()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Hiển thị nút Extract Text sau khi tải ảnh lên',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanPage()));
      await tester.pumpAndSettle();

      expect(find.text('Extract Text'), findsNothing);
    });

    testWidgets('Hiển thị nút Continue sau khi trích xuất văn bản',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanPage()));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsNothing);
    });
  });
}
