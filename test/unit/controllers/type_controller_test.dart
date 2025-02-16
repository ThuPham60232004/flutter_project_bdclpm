import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/type/controllers/type_page_controller.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('TypePageController', () {
    late TypePageController controller;
    late MockNavigatorObserver mockObserver;
    late BuildContext context;

    setUp(() {
      controller = TypePageController();
      mockObserver = MockNavigatorObserver();
      context = FakeBuildContext();
    });

testWidgets('selectOption updates selectedOption and navigates', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              controller.selectOption(context, TypePageController.manualvoice);
            },
            child: Text('Test'),
          );
        },
      ),
      routes: {'/manualvoice': (context) => Scaffold(body: Text('Next Page'))},
    ),
  );

  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  expect(find.text('Next Page'), findsOneWidget);
});


    test('selectOption không cập nhật nếu newValue là null', () {
      controller.selectOption(context, null);
      expect(controller.selectedOption, isNull);
    });

testWidgets('selectOption không điều hướng nếu newValue rỗng', (WidgetTester tester) async {
  final controller = TypePageController();

  await tester.pumpWidget(
    MaterialApp(
      routes: {
        TypePageController.manualvoice: (context) => Scaffold(body: Text('Manual Voice Page')),
        TypePageController.scan: (context) => Scaffold(body: Text('Scan Page')),
        TypePageController.pdfexcel: (context) => Scaffold(body: Text('PDF/Excel Page')),
      },
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              controller.selectOption(context, '');
            },
            child: Text('Test'),
          );
        },
      ),
    ),
  );

  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  expect(controller.selectedOption, isNull); 
});


    testWidgets('selectOption ném lỗi nếu không có Navigator', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container())); 

      final BuildContext validContext = tester.element(find.byType(Container));

      expect(() => controller.selectOption(validContext, TypePageController.manualvoice),
          throwsA(isA<FlutterError>()));
    });

  });
}

class FakeBuildContext extends Fake implements BuildContext {}
