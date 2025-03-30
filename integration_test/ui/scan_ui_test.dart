import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import '../../test/mocks/mocks.mocks.dart';
import 'dart:convert';

void main() {
  late MockImagePicker mockImagePicker;
  late MockCloudApi mockCloudApi;
  late MockFile mockFile;
  late Uint8List mockImageBytes;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockCloudApi = MockCloudApi();
    mockFile = MockFile();
    mockImageBytes = Uint8List.fromList([1, 2, 3]);

    when(mockFile.path).thenReturn('assets/images/hinh1.png');
    when(mockFile.readAsBytesSync()).thenReturn(mockImageBytes);
  });
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ScanPage(),
      ),
      routes: {
        '/scan-expense': (_) => Scaffold(body: Container()),
      },
    );
  }

testWidgets('Hiển thị hình ảnh đã chọn từ thư viện', (WidgetTester tester) async {
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
  expect(find.text('No image selected.'), findsNothing);
  expect(find.text('Upload to Cloud'), findsOneWidget);
  await tester.pumpAndSettle(Duration(seconds: 5));
  expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
  await tester.pumpAndSettle();
  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Upload to Cloud'));
  await tester.pumpAndSettle();
  await tester.pump(Duration(seconds: 10));
  expect(find.text('Extract Text'), findsOneWidget);
  expect(find.byIcon(Icons.text_snippet), findsOneWidget);
});
}
