import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/budget/presentation/add_budget.dart';

void main() {
  group('CreateBudgetScreen UI Test', () {
    testWidgets('Hiển thị tiêu đề và các trường nhập liệu',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CreateBudgetScreen()));

      expect(find.text('Ngân sách'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Số tiền'), findsOneWidget);
      expect(find.text('Ngày bắt đầu'), findsOneWidget);
      expect(find.text('Ngày kết thúc'), findsOneWidget);
      expect(find.text('Tạo ngân sách'), findsOneWidget);
      expect(find.text('Lịch ngân sách'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
