import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project_bdclpm/features/type/presentation/type_page.dart';
import 'package:flutter_project_bdclpm/features/type/controllers/type_page_controller.dart';
import '../../test/mocks/mocks_integration.mocks.dart';

Widget setupWidgetTest({required List<NavigatorObserver> observers}) {
  return MaterialApp(
    home: ChangeNotifierProvider(
      create: (_) => TypePageController(),
      child: const TypePage(),
    ),
    navigatorObservers: observers,
    routes: {
      TypePageController.manualvoice: (_) => Container(),
      TypePageController.scan: (_) => Container(),
      TypePageController.pdfexcel: (_) => Container(),
    },
  );
}

void main() {
  group('Kiểm thử giao diện TypePage', () {
    testWidgets('Nên chọn đúng tùy chọn và điều hướng chính xác', (WidgetTester tester) async {
      await tester.pumpWidget(setupWidgetTest(observers: []));
      await tester.pumpAndSettle();

      expect(find.text('Chọn kiểu nhập'), findsOneWidget);
      expect(find.text('Thêm chi tiêu'), findsOneWidget);
      expect(find.text('Bạn muốn nhập chi tiêu như thế nào'), findsOneWidget);
      expect(find.text('Nhập thủ công, giọng nói'), findsOneWidget);
      expect(find.text('Quét hóa đơn'), findsOneWidget);
      expect(find.text('Quét pdf/excel'), findsOneWidget);
      expect(find.byType(Radio<String>), findsNWidgets(3));
      final mockNavigatorObserver = MockNavigatorObserver();
      await tester.pumpWidget(setupWidgetTest(observers: [mockNavigatorObserver]));
      await tester.pumpAndSettle();

      final radioFinder = find.byType(Radio<String>);
      final radioCount = radioFinder.evaluate().length;
      print('Số lượng nút radio tìm thấy: $radioCount');

      radioFinder.evaluate().forEach((e) {
        print('Nút radio: ${e.widget}');
      });
      expect(radioCount, greaterThanOrEqualTo(3), reason: 'Cần có ít nhất 3 nút radio, nhưng chỉ tìm thấy $radioCount');

      final options = {
        'Nhập thủ công, giọng nói': TypePageController.manualvoice,
        'Quét hóa đơn': TypePageController.scan,
        'Quét pdf/excel': TypePageController.pdfexcel,
      };

      int index = 0;
      for (final entry in options.entries) {
        if (index >= radioCount) {
          fail('Chỉ số $index vượt quá số lượng radio có sẵn! Chỉ có $radioCount nút radio.');
        }

        print('Chọn nút radio $index: ${entry.key}');

        await tester.tap(radioFinder.at(index));
        await tester.pump();

        final selectedRadio = tester.widget<Radio<String>>(radioFinder.at(index));
        expect(selectedRadio.value, entry.value, reason: 'Nút radio ${entry.key} phải được chọn.');

        index++;
      }
    });
  });
}