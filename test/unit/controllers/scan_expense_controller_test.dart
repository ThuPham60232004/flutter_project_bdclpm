import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/mocks.mocks.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../test_config.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/scan_expense_controller.dart';

void main() {
  setupTestEnvironment();
  late MockCloudApi mockCloudApi;
  late MockClient mockHttpClient;
  late ScanExpenseController controller;
  late ImagePicker mockImagePicker;
  setUp(() {
    mockHttpClient = MockClient();
    controller = ScanExpenseController(httpClient: mockHttpClient);
    mockCloudApi = MockCloudApi();
    mockImagePicker = ImagePicker();
  });
  test('saveAndGetUrl should return a valid image URL', () async {
    final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
    final expectedUrl =
        'https://storage.googleapis.com/testflutter/hinh-anh-gia-lap.png';

    when(mockCloudApi.saveAndGetUrl(any, any))
        .thenAnswer((_) async => expectedUrl);

    final result = await mockCloudApi.saveAndGetUrl('hinh-anh.png', mockImage);

    expect(result, equals(expectedUrl));
  });

  test('extractTextFromImage should return extracted text', () async {
    final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
    final extractedText = 'Văn bản giả lập';

    when(mockCloudApi.extractTextFromImage(any))
        .thenAnswer((_) async => extractedText);

    final result = await mockCloudApi.extractTextFromImage(mockImage);

    expect(result, equals(extractedText));
  });

  test('extractTextFromImage should not return null', () async {
    final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
    final extractedText = 'Văn bản giả lập';

    when(mockCloudApi.extractTextFromImage(any))
        .thenAnswer((_) async => extractedText);

    final result = await mockCloudApi.extractTextFromImage(mockImage);

    expect(result, isNotNull);
    expect(result, isNotEmpty);
    expect(result, equals(extractedText));
  });
  test('Should load user ID from shared preferences', () async {
    SharedPreferences.setMockInitialValues({'userId': 'test_user'});
    await controller.loadUserId();
    expect(controller.userId, 'test_user');
  });

  test('Should convert date to ISO format', () {
    String isoDate = controller.convertToIsoDate('14/02/2025');
    expect(isoDate, '2025-02-14');
  });

  test('Should pick image and update state', () async {
    const MethodChannel imagePickerChannel =
        MethodChannel('plugins.flutter.io/image_picker');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      imagePickerChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'pickImage') {
          return 'assets/images/hcm_map.png';
        }
        return null;
      },
    );

    await controller.pickImage(ImageSource.gallery);

    expect(controller.image, isNotNull);
    expect(controller.imageBytes, isNotNull);
    expect(controller.imageName, isNotEmpty);
  });

  test('Lưu hình ảnh và trả về url', () async {
    final Uint8List mockImageBytes = Uint8List.fromList([0, 1, 2, 3]);
    controller.imageBytes = mockImageBytes;
    controller.imageName = 'test.png';

    when(mockCloudApi.saveAndGetUrl(any, any)).thenAnswer(
        (_) async => 'https://storage.googleapis.com/testflutter/test.png');

    await controller.saveImage(mockCloudApi);
    expect(controller.imageUrl, contains('test.png'));
    expect(controller.isUploaded, true);
  });

  test('Phân tích từ hình ảnh', () async {
    final Uint8List mockImageBytes = Uint8List.fromList([0, 1, 2, 3]);
    controller.imageBytes = mockImageBytes;

    when(mockCloudApi.extractTextFromImage(any)).thenAnswer((_) async =>
        jsonEncode({'status': 'success', 'text': 'Sample extracted text'}));

    await controller.extractText(mockCloudApi);
    expect(controller.extractedText, contains('Sample extracted text'));
  });
  test('Should add expense successfully', () async {
    controller.userId = 'test_user';
    final storeName = 'Test Store';
    final totalAmount = 150000.0;
    final description = 'Test purchase';
    final date = '25/02/2025';
    final categoryId = 'food';

    final mockResponse = http.Response('{}', 201);

    when(mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => mockResponse);

    await controller.createExpense(
      storeName: storeName,
      totalAmount: totalAmount,
      description: description,
      date: date,
      categoryId: categoryId,
    );

    verify(mockHttpClient.post(
      Uri.parse("https://backend-bdclpm.onrender.com/api/expenses"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": 'test_user',
        "storeName": storeName,
        "totalAmount": totalAmount,
        "description": description,
        "date": "2025-02-25",
        "categoryId": categoryId,
      }),
    )).called(1);
  });
}
