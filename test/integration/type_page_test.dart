import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/type/presentation/type_page.dart';

void main() {
  group('TypePage UI Test', () {
    testWidgets('Hiển thị tiêu đề và các tùy chọn nhập chi tiêu',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TypePage()));

      expect(find.text('Chọn kiểu nhập'), findsOneWidget);
      expect(find.text('Thêm chi tiêu'), findsOneWidget);
      expect(find.text('Bạn muốn nhập chi tiêu như thế nào'), findsOneWidget);
      expect(find.text('Nhập thủ công, giọng nói'), findsOneWidget);
      expect(find.text('Quét hóa đơn'), findsOneWidget);
      expect(find.text('Quét pdf/excel'), findsOneWidget);
      expect(find.byType(Radio<String>), findsNWidgets(3));
    });
  });
}
