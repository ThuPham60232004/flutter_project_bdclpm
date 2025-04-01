import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:provider/provider.dart';
import '../../../test/mocks/mocks.mocks.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MockCloudApi mockCloudApi;
  setUp(() async {
    SharedPreferences.setMockInitialValues({}); 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', '678cf5b1e729fb9da673725c');
    HttpOverrides.global = null;
    mockCloudApi = MockCloudApi();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<CloudApi>.value(value: mockCloudApi),
      ],
      child: MaterialApp(
        home: ScanPage(),
      ),
    );
  }

  group('ScanPage Functional Tests', () {
    testWidgets('Hoàn tất quy trình tải lên hình ảnh và trích xuất văn bản đầy đủ, dùng dữ liệu thật',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      await tester.pump(Duration(seconds: 8));
      expect(find.byType(Image), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Upload to Cloud'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload to Cloud'));
      await tester.pump();
      await tester.pumpAndSettle(Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Image uploaded successfully!'), findsOneWidget);
      await tester.pump(Duration(seconds: 25));
      await tester.ensureVisible(find.text('Extract Text'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Extract Text'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
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
      await tester.tap(find.text('Lưu chi tiêu'));
      await tester.pumpAndSettle();
    });
  });
}
