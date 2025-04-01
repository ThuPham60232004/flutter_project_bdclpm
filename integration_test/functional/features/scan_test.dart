import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan_expense_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../test/mocks/mocks.mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
void main() {
  late MockAuthClientWrapper mockAuthWrapper;
  late MockCloudApi mockCloudApi;
  late MockImagePicker mockImagePicker;
  late MockXFile mockXFile;
  late Uint8List mockImageBytes;
  late MockClient mockHttpClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', '678cf5b1e729fb9da673725c');
    HttpOverrides.global = null;
    mockAuthWrapper = MockAuthClientWrapper();
    mockCloudApi = MockCloudApi();
    mockImagePicker = MockImagePicker();
    mockXFile = MockXFile();
    mockHttpClient = MockClient();
    mockImageBytes = Uint8List.fromList([1, 2, 3]);

    when(mockXFile.path).thenReturn('assets/images/hcm_map.png');
    when(mockXFile.readAsBytes()).thenAnswer((_) async => mockImageBytes);
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

  Widget createExpenseWidgetUnderTest() {
    return MaterialApp(
      home: ScanExpensePage(
        storeName: 'quan an thien tan',
        totalAmount: 100000,
        description: 'Các mặt hàng liên quan đến thực phẩm',
        date: '2023-01-01',
        categoryId: '678d18f502455271e95277b4',
        categoryname: 'Thực phẩm',
        currency: 'VND',
      ),
    );
  }

  group('ScanPage Tests', () {
    testWidgets('TC08: Normal Cases - Kiểm tra tải ảnh lên thành công với dữ liệu thật', 
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
    });
    testWidgets('TC09: Abnormal Cases - Hiển thị lỗi khi tải lên hình ảnh không thành công', (WidgetTester tester) async {
      when(mockCloudApi.saveAndGetUrl(any, any)).thenThrow(Exception('Upload failed'));
      
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
      
      expect(find.text('Error uploading image'), findsOneWidget);
    });

    testWidgets('TC10: Hiển thị lỗi khi trích xuất văn bản không thành công', (WidgetTester tester) async {
      when(mockCloudApi.saveAndGetUrl(any, any)).thenAnswer((_) async => 'http://example.com/image.jpg');
      when(mockCloudApi.extractTextFromImage(any)).thenThrow(Exception('Extraction failed'));
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
      
      expect(find.text('Error extracting text. Please try again.'), findsOneWidget);
    });
    testWidgets('TC11: Boundary Cases - Xử lý kích thước hình ảnh tối đa', (WidgetTester tester) async {
      final largeImageBytes = Uint8List(10 * 1024 * 1024); 
      when(mockXFile.readAsBytes()).thenAnswer((_) async => largeImageBytes);
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
    });
    testWidgets('TC12: Normal Cases - Xử lý các phản hồi API thành công', (WidgetTester tester) async {
      when(mockCloudApi.saveAndGetUrl(any, any)).thenAnswer((_) async => 'http://example.com/image.jpg');
      when(mockCloudApi.extractTextFromImage(any)).thenAnswer((_) async => 
        jsonEncode({'status': 'success', 'data': {}})
      );
      
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
    });

    testWidgets('TH13: Abnormal Cases - Xử lý phản hồi 401', (WidgetTester tester) async {
      when(mockCloudApi.saveAndGetUrl(any, any)).thenThrow(
        http.ClientException('Unauthorized', Uri.parse('https://example.com'))
      );
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
      
      expect(find.textContaining('Unauthorized'), findsOneWidget);
    });

    testWidgets('TH14: Abnormal Cases - Xử lý phản hồi lỗi máy chủ 500', (WidgetTester tester) async {
      when(mockCloudApi.saveAndGetUrl(any, any)).thenThrow(
        http.ClientException('Server Error', Uri.parse('https://example.com'))
      );
      
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
      
      expect(find.textContaining('Server Error'), findsOneWidget);
    });
  });

  group('ScanExpensePage Tests', () {
    testWidgets('TC15: Normal Cases - Gửi biểu mẫu Scan Expense Page với dữ liệu hợp lệ', (WidgetTester tester) async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"status": "success"}', 201));
      
        await tester.pumpWidget(createWidgetUnderTest());
        expect(find.text('Upload to Google Cloud'), findsOneWidget);
        expect(find.text('No image selected.'), findsOneWidget);
        await tester.tap(find.byType(FloatingActionButton));
        expect(find.byType(FloatingActionButton), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text('Take a photo'), findsOneWidget);
        expect(find.text('Choose from gallery'), findsOneWidget);
        expect(find.byIcon(Icons.camera), findsOneWidget);
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
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
        await tester.pump(Duration(seconds: 10));
        expect(find.text('Extract Text'), findsOneWidget);
        expect(find.byIcon(Icons.text_snippet), findsOneWidget);
      
        expect(find.text('Chi tiêu đã được tạo thành công'), findsOneWidget);
    });

    testWidgets('TC16: Abnormal Cases - Hiển thị lỗi xác thực cho biểu mẫu Scan Expense Page trống', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ScanExpensePage(
          storeName: '',
          totalAmount: 0,
          description: '',
          date: '',
          categoryId: '',
          categoryname: '',
          currency: 'VND',
        ),
      ));
      
      await tester.tap(find.text('Lưu chi tiêu'));
      await tester.pumpAndSettle();
      
      expect(find.text('Vui lòng nhập tên cửa hàng'), findsOneWidget);
      expect(find.text('Vui lòng nhập số tiền'), findsOneWidget);
    });

    testWidgets('TC17: Hiển thị lỗi ở định dạng số tiền không hợp lệ', (WidgetTester tester) async {
      await tester.pumpWidget(createExpenseWidgetUnderTest());
      
      await tester.enterText(find.byKey(Key('amountField')), 'abc');
      await tester.tap(find.text('Lưu chi tiêu'));
      await tester.pumpAndSettle();
      
      expect(find.text('Số tiền phải là số'), findsOneWidget);
    });

    testWidgets('TC18: Boundary Cases - Xử lý giá trị số tiền tối đa', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ScanExpensePage(
          storeName: 'quan an thien tan',
          totalAmount: 999999999999,
          description: 'Test',
          date: '2023-01-01',
          categoryId: '678d18f502455271e95277b4',
          categoryname: 'Thực phẩm',
          currency: 'VND',
        ),
      ));
      
      await tester.tap(find.text('Lưu chi tiêu'));
      await tester.pumpAndSettle();
      expect(find.text('999,999,999,999'), findsOneWidget);
    });

    testWidgets('TC19: Normal Cases - Xử lý việc tạo chi tiêu thành công', (WidgetTester tester) async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"status": "success"}', 201));
      
      await tester.pumpWidget(createExpenseWidgetUnderTest());
      
      await tester.tap(find.text('Lưu chi tiêu'));
      await tester.pumpAndSettle();
      
      expect(find.text('Chi tiêu đã được tạo thành công'), findsOneWidget);
    });

    testWidgets('TC20: Abnormal Cases - Xử lý phản hồi 400 yêu cầu xấu', (WidgetTester tester) async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"error": "Invalid data"}', 400));
      
      await tester.pumpWidget(createExpenseWidgetUnderTest());
      
      await tester.tap(find.text('Lưu chi tiêu'));
      await tester.pumpAndSettle();
      
      expect(find.text('Invalid data'), findsOneWidget);
    });

    testWidgets('TC21: Abnormal Cases -  Xử lý phản hồi lỗi máy chủ 500', (WidgetTester tester) async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('Server Error', 500));
      
      await tester.pumpWidget(createExpenseWidgetUnderTest());
      
      await tester.tap(find.text('Lưu chi tiêu'));
      await tester.pumpAndSettle();
      
      expect(find.text('Server Error'), findsOneWidget);
    });

    testWidgets('TC22: Boundary Transaction Case - Xử lý chuyển đổi tiền tệ từ nước ngoài sang VNĐ', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ScanExpensePage(
          storeName: 'quan an thien tan',
          totalAmount: 100,
          description: 'Test',
          date: '2023-01-01',
          categoryId: '678d18f502455271e95277b4',
          categoryname: 'Thực phẩm',
          currency: 'USD',
        ),
      ));
      
      await tester.tap(find.text('USD'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('VND'));
      await tester.pumpAndSettle();
      
      expect(find.text('2,300,000'), findsOneWidget);
    });
  });
}