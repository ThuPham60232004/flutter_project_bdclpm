import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/mocks.mocks.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../test_config.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/scan_expense_controller.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

void main() {
  setupTestEnvironment();
  late MockCloudApi mockCloudApi;
  late MockClient mockHttpClient;
  late MockAuthClient mockAuthClient;
  late ScanExpenseController controller;
  late ImagePicker mockImagePicker;
  late CloudApi cloudApi;
  late MockAuthClientWrapper mockAuthClientWrapper;
  setUp(() {
    mockHttpClient = MockClient();
    mockAuthClient = MockAuthClient();
    mockCloudApi = MockCloudApi();
    mockImagePicker = MockImagePicker();
    mockAuthClientWrapper = MockAuthClientWrapper();
    cloudApi = CloudApi(mockAuthClientWrapper);
    controller = ScanExpenseController(httpClient: mockHttpClient);
  });
  group('loadUserId()', () {
    test('Nên tải ID người dùng nếu tồn tại trong SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(
          {'userId': '678cf5b1e729fb9da673725c'});

      await controller.loadUserId();

      bool result = controller.userId == '678cf5b1e729fb9da673725c';
      print('So sánh userId: $result');

      expect(result, true);
    });

    test('Nên để userId là null nếu không tồn tại trong SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({});

      await controller.loadUserId();

      bool result = controller.userId == null;
      print('So sánh userId khi không có trong SharedPreferences: $result');

      expect(result, true);
    });
  });
  group('convertToIsoDate', () {
    test('Trả về nguyên giá trị nếu ngày đã đúng định dạng yyyy-MM-dd', () {
      String result = controller.convertToIsoDate('2024-03-17');
      bool comparison = result == '2024-03-17';

      print('So sánh ngày yyyy-MM-dd: $comparison');

      expect(comparison, true);
    });

    test('Chuyển đổi ngày từ dd/MM/yyyy sang yyyy-MM-dd', () {
      String result = controller.convertToIsoDate('17/03/2024');
      bool comparison = result == '2024-03-17';

      print('So sánh chuyển đổi dd/MM/yyyy -> yyyy-MM-dd: $comparison');

      expect(comparison, true);
    });

    test('Ném Exception nếu ngày sai định dạng', () {
      expect(() => controller.convertToIsoDate('03-17-2024'), throwsException);
      expect(() => controller.convertToIsoDate('ngày 17 tháng 3'),
          throwsException);

      print('Kiểm tra ngoại lệ với ngày sai định dạng: true');
    });

    test('Ném Exception nếu ngày null hoặc rỗng', () {
      expect(() => controller.convertToIsoDate(''), throwsException);
      expect(() => controller.convertToIsoDate('   '), throwsException);

      print('Kiểm tra ngoại lệ với ngày rỗng: true');
    });
  });

  group('pickImage()', () {
    test('Chọn hình ảnh từ camera và cập nhật trạng thái', () async {
      const MethodChannel imagePickerChannel =
          MethodChannel('plugins.flutter.io/image_picker');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(imagePickerChannel,
              (MethodCall methodCall) async {
        if (methodCall.method == 'pickImage') {
          return 'assets/images/hcm_map.png';
        }
        return null;
      });

      await controller.pickImage(ImageSource.camera);

      bool comparison = controller.image != null &&
          controller.imageName == 'hcm_map.png' &&
          controller.isUploaded == false;
      print('So sánh chọn ảnh từ camera: $comparison');

      expect(comparison, true);
    });

    test('Chọn ảnh từ thư viện thành công', () async {
      const MethodChannel imagePickerChannel =
          MethodChannel('plugins.flutter.io/image_picker');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(imagePickerChannel,
              (MethodCall methodCall) async {
        if (methodCall.method == 'pickImage') {
          return 'assets/images/hcm_map.png';
        }
        return null;
      });

      await controller.pickImage(ImageSource.gallery);

      bool comparison = controller.image != null &&
          controller.imageName == 'hcm_map.png' &&
          controller.isUploaded == false;
      print('So sánh chọn ảnh từ thư viện: $comparison');

      expect(comparison, true);
    });

    test('Đưa vào đường dẫn không tồn tại', () async {
      const MethodChannel imagePickerChannel =
          MethodChannel('plugins.flutter.io/image_picker');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(imagePickerChannel,
              (MethodCall methodCall) async {
        if (methodCall.method == 'pickImage') {
          return 'assets/images/unknown.png'; // Không tồn tại
        }
        return null;
      });

      await controller.pickImage(ImageSource.gallery);

      bool comparison = controller.image != null &&
          controller.imageName == 'unknown.png' &&
          controller.isUploaded == false;
      print('So sánh chọn ảnh với đường dẫn không tồn tại: $comparison');

      expect(comparison, true);
    });

    test('Gây lỗi khi chọn ảnh từ camera (Exception)', () async {
      when(mockImagePicker.pickImage(source: ImageSource.camera))
          .thenThrow(Exception('Lỗi khi chọn ảnh từ camera'));

      expect(() => controller.pickImage(ImageSource.camera), throwsException);

      print('So sánh lỗi khi chọn ảnh từ camera: true');
    });
  });

  group('saveImage()', () {
    test('Ném Exception khi imageBytes == null', () async {
      controller.imageBytes = null;
      controller.imageName = 'mock.jpg';

      print(
          'So sánh throwsException: ${() => controller.saveImage(mockCloudApi) is Exception}');
      expect(() => controller.saveImage(mockCloudApi), throwsException);
    });

    test('Không lỗi khi imageBytes != null', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = 'mock.jpg';
      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => 'http://mock.url');

      print(
          'So sánh returnsNormally: ${() => controller.saveImage(mockCloudApi) is! Exception}');
      expect(() => controller.saveImage(mockCloudApi), returnsNormally);
    });

    test('Ném Exception khi imageName == null', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = null;

      print(
          'So sánh throwsException: ${() => controller.saveImage(mockCloudApi) is Exception}');
      expect(() => controller.saveImage(mockCloudApi), throwsException);
    });

    test('Không lỗi khi imageName != null', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = 'mock.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => 'http://mock.url');

      print(
          'So sánh returnsNormally: ${() => controller.saveImage(mockCloudApi) is! Exception}');
      expect(() => controller.saveImage(mockCloudApi), returnsNormally);
    });

    test('loading = true khi bắt đầu upload', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = 'mock.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => 'http://mock.url');

      final future = controller.saveImage(mockCloudApi);
      print('So sánh loading trước await: ${controller.loading == true}');
      expect(controller.loading, true);

      await future;
    });

    test('imageUrl được cập nhật khi API thành công', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = 'mock.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => 'http://mock.url');

      await controller.saveImage(mockCloudApi);

      print('So sánh imageUrl: ${controller.imageUrl == "http://mock.url"}');
      expect(controller.imageUrl, 'http://mock.url');
    });

    test('Ném Exception khi API gặp lỗi', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = 'mock.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenThrow(Exception('Lỗi server'));

      print(
          'So sánh throwsException: ${() => controller.saveImage(mockCloudApi) is Exception}');
      expect(() => controller.saveImage(mockCloudApi), throwsException);
    });

    test('isUploaded = true khi ảnh lưu thành công', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = 'mock.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => 'http://mock.url');

      await controller.saveImage(mockCloudApi);

      print('So sánh isUploaded: ${controller.isUploaded == true}');
      expect(controller.isUploaded, true);
    });

    test('Ném Exception khi API thất bại (catch (e))', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = 'mock.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenThrow(Exception('Lỗi khi upload'));

      print(
          'So sánh throwsException: ${() => controller.saveImage(mockCloudApi) is Exception}');
      expect(() => controller.saveImage(mockCloudApi), throwsException);
    });

    test('loading = false trong finally dù thành công hay thất bại', () async {
      controller.imageBytes = Uint8List(10);
      controller.imageName = 'mock.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => 'http://mock.url');

      await controller.saveImage(mockCloudApi);
      print('So sánh loading sau thành công: ${controller.loading == false}');
      expect(controller.loading, false);

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenThrow(Exception('Lỗi API'));

      try {
        await controller.saveImage(mockCloudApi);
      } catch (_) {}

      print('So sánh loading sau thất bại: ${controller.loading == false}');
      expect(controller.loading, false);
    });
  });

  group('extractText()', () {
    test('Ném Exception khi imageBytes == null', () async {
      controller.imageBytes = null;

      print(
          'So sánh throwsException: ${() => controller.extractText(mockCloudApi) is Exception}');
      expect(() => controller.extractText(mockCloudApi), throwsException);
    });

    test('loading = true khi bắt đầu extract', () async {
      controller.imageBytes = Uint8List(10);

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => '{"text": "sample"}');

      final future = controller.extractText(mockCloudApi);

      print('So sánh loading trước await: ${controller.loading == true}');
      expect(controller.loading, true);

      await future;
    });

    test('extractedText cập nhật đúng khi API trả JSON hợp lệ', () async {
      controller.imageBytes = Uint8List(10);
      final mockResponse = '{"text": "sample extracted text"}';

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => mockResponse);

      await controller.extractText(mockCloudApi);

      final expectedText =
          JsonEncoder.withIndent("  ").convert(json.decode(mockResponse));
      print(
          'So sánh extractedText: ${controller.extractedText == expectedText}');
      expect(controller.extractedText, expectedText);
    });

    test('Ném Exception khi API gặp lỗi', () async {
      controller.imageBytes = Uint8List(10);

      when(mockCloudApi.extractTextFromImage(any))
          .thenThrow(Exception('Lỗi server'));

      print(
          'So sánh throwsException: ${() => controller.extractText(mockCloudApi) is Exception}');
      expect(() => controller.extractText(mockCloudApi), throwsException);
    });

    test('Ném Exception khi resultJson bị lỗi hoặc sai định dạng', () async {
      controller.imageBytes = Uint8List(10);
      final mockInvalidResponse = 'INVALID_JSON';

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => mockInvalidResponse);

      print(
          'So sánh throwsException: ${() => controller.extractText(mockCloudApi) is Exception}');
      expect(() => controller.extractText(mockCloudApi), throwsException);
    });

    test('loading = false trong finally dù thành công hay thất bại', () async {
      controller.imageBytes = Uint8List(10);

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => '{"text": "sample"}');

      await controller.extractText(mockCloudApi);
      print('So sánh loading sau thành công: ${controller.loading == false}');
      expect(controller.loading, false);

      when(mockCloudApi.extractTextFromImage(any))
          .thenThrow(Exception('Lỗi API'));

      try {
        await controller.extractText(mockCloudApi);
      } catch (_) {}

      print('So sánh loading sau thất bại: ${controller.loading == false}');
      expect(controller.loading, false);
    });
  });

  group('extractText()', () {
    test('Ném Exception khi imageBytes == null', () async {
      controller.imageBytes = null;

      expect(() => controller.extractText(mockCloudApi), throwsException);
    });

    test('Không lỗi khi imageBytes != null', () async {
      controller.imageBytes = Uint8List(10);

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => '{"text": "sample"}');

      expect(() => controller.extractText(mockCloudApi), returnsNormally);
    });

    test('loading = true khi bắt đầu extract', () async {
      controller.imageBytes = Uint8List(10);

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => '{"text": "sample"}');

      final future = controller.extractText(mockCloudApi);
      expect(controller.loading, true);

      await future;
    });

    test('extractedText cập nhật đúng khi API trả JSON hợp lệ', () async {
      controller.imageBytes = Uint8List(10);
      final mockResponse = '{"text": "sample extracted text"}';

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => mockResponse);

      await controller.extractText(mockCloudApi);

      expect(controller.extractedText,
          JsonEncoder.withIndent("  ").convert(json.decode(mockResponse)));
    });

    test('Ném Exception khi API gặp lỗi', () async {
      controller.imageBytes = Uint8List(10);

      when(mockCloudApi.extractTextFromImage(any))
          .thenThrow(Exception('Lỗi server'));

      expect(() => controller.extractText(mockCloudApi), throwsException);
    });

    test('Ném Exception khi resultJson bị lỗi hoặc sai định dạng', () async {
      controller.imageBytes = Uint8List(10);
      final mockInvalidResponse = 'INVALID_JSON';

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => mockInvalidResponse);

      expect(() => controller.extractText(mockCloudApi), throwsException);
    });

    test('loading = false trong finally dù thành công hay thất bại', () async {
      controller.imageBytes = Uint8List(10);

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => '{"text": "sample"}');

      await controller.extractText(mockCloudApi);
      expect(controller.loading, false);

      when(mockCloudApi.extractTextFromImage(any))
          .thenThrow(Exception('Lỗi API'));

      try {
        await controller.extractText(mockCloudApi);
      } catch (_) {}

      expect(controller.loading, false);
    });
  });
  group('formatCurrency()', () {
    test('amount hợp lệ', () {
      print('So sánh 1000: ${controller.formatCurrency(1000) == '1.000'}');
      expect(controller.formatCurrency(1000), '1.000');

      print(
          'So sánh 1234567: ${controller.formatCurrency(1234567) == '1.234.567'}');
      expect(controller.formatCurrency(1234567), '1.234.567');

      print(
          'So sánh 999999999: ${controller.formatCurrency(999999999) == '999.999.999'}');
      expect(controller.formatCurrency(999999999), '999.999.999');

      print('So sánh 0: ${controller.formatCurrency(0) == '0'}');
      expect(controller.formatCurrency(0), '0');
    });

    test('amount không hợp lệ', () {
      print(
          'So sánh NaN throwsException: ${() => controller.formatCurrency(double.nan) is Exception}');
      expect(() => controller.formatCurrency(double.nan),
          throwsA(isA<FormatException>()));

      print(
          'So sánh Infinity throwsException: ${() => controller.formatCurrency(double.infinity) is Exception}');
      expect(() => controller.formatCurrency(double.infinity),
          throwsA(isA<FormatException>()));

      print(
          'So sánh Negative Infinity throwsException: ${() => controller.formatCurrency(double.negativeInfinity) is Exception}');
      expect(() => controller.formatCurrency(double.negativeInfinity),
          throwsA(isA<FormatException>()));
    });
  });

  group('createExpense()', () {
    test('Ném Exception khi userId == null', () async {
      controller.userId = null;

      expect(
        () => controller.createExpense(
          storeName: 'quan an thien tan',
          totalAmount: 100.0,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '2025-03-17',
          categoryId: '678d18f502455271e95277b4',
        ),
        throwsException,
      );
    });

    test('Không lỗi khi userId hợp lệ', () async {
      controller.userId = 'user123';

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{}', 201));

      expect(
        () => controller.createExpense(
          storeName: 'quan an thien tan',
          totalAmount: 100.0,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '2025-03-17',
          categoryId: '678d18f502455271e95277b4',
        ),
        returnsNormally,
      );
    });

    test('expenseData có đủ dữ liệu hợp lệ', () async {
      controller.userId = 'user123';

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{}', 201));

      final expectedExpenseData = {
        "userId": "user123",
        "storeName": "quan an thien tan",
        "totalAmount": 100.0,
        "description": "Các mặt hàng liên quan đến thực phẩm",
        "date": "2025-03-17", 
        "categoryId": "678d18f502455271e95277b4",
      };

      await controller.createExpense(
        storeName: 'quan an thien tan',
        totalAmount: 100.0,
        description: 'Các mặt hàng liên quan đến thực phẩm',
        date: '2025-03-17',
        categoryId: '678d18f502455271e95277b4',
      );

      verify(mockHttpClient.post(
        Uri.parse("https://backend-bdclpm.onrender.com/api/expenses"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(expectedExpenseData),
      )).called(1);
    });

    test(
        'Ném Exception khi thiếu storeName, totalAmount, description, date hoặc categoryId',
        () async {
      controller.userId = 'user123';

      expect(
        () => controller.createExpense(
          storeName: '',
          totalAmount: 100.0,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '2025-03-17',
          categoryId: '678d18f502455271e95277b4',
        ),
        throwsException,
      );

      expect(
        () => controller.createExpense(
          storeName: 'quan an thien tan',
          totalAmount: 0.0,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '2025-03-17',
          categoryId: '678d18f502455271e95277b4',
        ),
        throwsException,
      );

      expect(
        () => controller.createExpense(
          storeName: 'quan an thien tan',
          totalAmount: 100.0,
          description: '',
          date: '2025-03-17',
          categoryId: '678d18f502455271e95277b4',
        ),
        throwsException,
      );

      expect(
        () => controller.createExpense(
          storeName: 'quan an thien tan',
          totalAmount: 100.0,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '',
          categoryId: '678d18f502455271e95277b4',
        ),
        throwsException,
      );

      expect(
        () => controller.createExpense(
          storeName: 'quan an thien tan',
          totalAmount: 100.0,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '2025-03-17',
          categoryId: '',
        ),
        throwsException,
      );
    });

    test('date được chuyển đổi đúng sang ISO format', () async {
      controller.userId = 'user123';

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{}', 201));

      await controller.createExpense(
        storeName: 'quan an thien tan',
        totalAmount: 100.0,
        description: 'Các mặt hàng liên quan đến thực phẩm',
        date: '17/03/2025',
        categoryId: '678d18f502455271e95277b4',
      );

      final captured = verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured.single;

      final decodedBody = jsonDecode(captured);

      expect(decodedBody['date'], '2025-03-17');
    });

    test('Ném Exception khi API trả về lỗi', () async {
      controller.userId = 'user123';

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer(
              (_) async => http.Response('{"message": "Lỗi API"}', 400));

      expect(
        () => controller.createExpense(
          storeName: 'quan an thien tan',
          totalAmount: 100.0,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '2025-03-17',
          categoryId: '678d18f502455271e95277b4',
        ),
        throwsException,
      );
    });

    test('Ném Exception khi API gặp lỗi mạng', () async {
      controller.userId = 'user123';

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Lỗi mạng'));

      expect(
        () => controller.createExpense(
          storeName: 'quan an thien tan',
          totalAmount: 100.0,
          description: 'Các mặt hàng liên quan đến thực phẩm',
          date: '2025-03-17',
          categoryId: '678d18f502455271e95277b4',
        ),
        throwsException,
      );
    });
  });
  group('Scan Expense Controller', () {
    test('Lưu hình ảnh và trả về url', () async {
      final Uint8List mockImageBytes = Uint8List.fromList([0, 1, 2, 3]);
      controller.imageBytes = mockImageBytes;
      controller.imageName = 'test.png';

      when(mockCloudApi.saveAndGetUrl(any, any)).thenAnswer(
          (_) async => 'https://storage.googleapis.com/testflutter/test.png');

      await controller.saveImage(mockCloudApi);

      bool success = (controller.imageUrl?.contains('test.png') ?? false) &&
      controller.isUploaded == true;

      print('Test "Lưu hình ảnh và trả về url": $success');
      expect(success, true);
    });

    test('Phân tích từ hình ảnh', () async {
      final Uint8List mockImageBytes = Uint8List.fromList([0, 1, 2, 3]);
      controller.imageBytes = mockImageBytes;

      when(mockCloudApi.extractTextFromImage(any)).thenAnswer((_) async =>
          jsonEncode({'status': 'success', 'text': 'Sample extracted text'}));

      await controller.extractText(mockCloudApi);

      bool success = controller.extractedText.contains('Sample extracted text');

      print('Test "Phân tích từ hình ảnh": $success');
      expect(success, true);
    });

    test('Nên thêm chi phí thành công', () async {
      controller.userId = '678cf5b1e729fb9da673725c';
      final storeName = 'quan an thien tan';
      final totalAmount = 150000.0;
      final description = 'Test purchase';
      final date = '25/02/2025';
      final categoryId = '678d18f502455271e95277b4';

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

      final captured = verify(mockHttpClient.post(
        Uri.parse("https://backend-bdclpm.onrender.com/api/expenses"),
        headers: {"Content-Type": "application/json"},
        body: captureAnyNamed('body'),
      )).captured.single;

      final decodedBody = jsonDecode(captured);
      bool success = decodedBody['userId'] == '678cf5b1e729fb9da673725c' &&
          decodedBody['storeName'] == storeName &&
          decodedBody['totalAmount'] == totalAmount &&
          decodedBody['description'] == description &&
          decodedBody['date'] == '2025-02-25' &&
          decodedBody['categoryId'] == categoryId;

      print('Test "Nên thêm chi phí thành công": $success');
      expect(success, true);
    });
  });
}
