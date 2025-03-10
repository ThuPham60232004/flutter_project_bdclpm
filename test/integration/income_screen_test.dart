import 'package:flutter_project_bdclpm/features/income/presentation/income.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('IncomeScreen UI Test', (WidgetTester tester) async {
    // Build IncomeScreen
    await tester.pumpWidget(
      MaterialApp(
        home: IncomeScreen(),
      ),
    );
    expect(find.text("Chatbot Tài Chính"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
    await tester.enterText(find.byType(TextField), "Xin chào");
    expect(find.text("Xin chào"), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text("Xin chào"), findsNothing);
  });
}
