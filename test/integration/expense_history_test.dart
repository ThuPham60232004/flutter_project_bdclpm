import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bdclpm/features/history/presentation/history_page.dart';

void main() {
  group('HistoryPage UI Test', () {
    testWidgets('HistoryPage UI Test', (WidgetTester tester) async {
      final mockOrders = [
        {
          'storeName': 'Cửa hàng ABC',
          'date': '2024-03-10',
          'totalAmount': -50000,
          'description': 'Mua đồ ăn',
          'categoryId': {'icon': 'food', 'name': 'Ăn uống'}
        },
        {
          'storeName': 'Điện Máy Xanh',
          'date': '2024-03-09',
          'totalAmount': 300000,
          'description': 'Bán điện thoại cũ',
          'categoryId': {'icon': 'devices', 'name': 'Thiết bị'}
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: HistoryPage(),
        ),
      );

      expect(find.text('Lịch Sử Giao Dịch'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.runAsync(() async {
        final state = tester.state<HistoryPageState>(find.byType(HistoryPage));
        state.setState(() {
          state.orders = mockOrders;
          state.isLoading = false;
        });
      });

      await tester.pumpAndSettle();

      expect(find.text('Cửa hàng ABC'), findsOneWidget);
      expect(find.text('Mua đồ ăn'), findsOneWidget);
      expect(find.text('-50000 VND'), findsOneWidget);
      expect(find.text('Điện Máy Xanh'), findsOneWidget);
      expect(find.text('Bán điện thoại cũ'), findsOneWidget);
      expect(find.text('+300000 VND'), findsOneWidget);
    });

    testWidgets('HistoryPage shows empty message when no transactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HistoryPage()));

      await tester.runAsync(() async {
        final state = tester.state<HistoryPageState>(find.byType(HistoryPage));
        state.setState(() {
          state.orders = [];
          state.isLoading = false;
        });
      });

      await tester.pumpAndSettle();

      expect(find.text('Không có giao dịch nào.'), findsOneWidget);
    });
  });
}
