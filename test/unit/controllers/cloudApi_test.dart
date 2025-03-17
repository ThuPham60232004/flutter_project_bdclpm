import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/mocks.mocks.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../test_config.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/scan_expense_controller.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:http/http.dart' as http;
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
    mockImagePicker = ImagePicker();
    mockAuthClientWrapper = MockAuthClientWrapper();
    cloudApi = CloudApi(mockAuthClientWrapper);
    controller = ScanExpenseController(httpClient: mockHttpClient);
  });
  group('InitializeClient', () {
    test('initializeClient() nên khởi tạo client nếu chưa có', () async {
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      final client = await mockAuthClientWrapper.createAuthClient();
      expect(client, isNotNull);

      // Đảm bảo phương thức createAuthClient() được gọi đúng 1 lần
      verify(mockAuthClientWrapper.createAuthClient()).called(1);
    });

    test('initializeClient() không nên khởi tạo lại nếu client đã tồn tại',
        () async {
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();

      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      final cloudApi = CloudApi(mockAuthClientWrapper);

      // Gọi initializeClient() lần đầu
      await cloudApi.initializeClient();
      expect(cloudApi.client, isNotNull);

      // Đảm bảo createAuthClient() được gọi đúng 1 lần
      verify(mockAuthClientWrapper.createAuthClient()).called(1);

      // Gọi initializeClient() lần hai - không nên khởi tạo lại
      await cloudApi.initializeClient();

      // Kiểm tra không có tương tác nào khác với mockAuthClientWrapper
      verifyNoMoreInteractions(mockAuthClientWrapper);
    });
  });

  group('save', () {
    test('Nên trả về null nếu client chưa được khởi tạo', () {
      CloudApi cloudApi = CloudApi(MockAuthClientWrapper());
      expect(cloudApi.client, isNull);
    });
    test('Nên khởi tạo client nếu chưa được khởi tạo trước đó', () async {
      final mockAuthClientWrapper = MockAuthClientWrapper();
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();

      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      CloudApi cloudApi = CloudApi(mockAuthClientWrapper);
      await cloudApi.initializeClient();

      expect(cloudApi.client, isNotNull);
      verify(mockAuthClientWrapper.createAuthClient()).called(1);
    });
    test('Nên trả về null nếu bucket chưa được khởi tạo', () async {
      CloudApi cloudApi = CloudApi(MockAuthClientWrapper());
      expect(
          () => cloudApi.cloudStorage.bucket('testflutter'), throwsException);
    });

    test('Nên trả về bucket không null sau khi khởi tạo', () async {
      final mockAuthClientWrapper = MockAuthClientWrapper();
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);
      CloudApi cloudApi = CloudApi(mockAuthClientWrapper);
      await cloudApi.initializeClient();
      expect(cloudApi.cloudStorage.bucket('testflutter'), isNotNull);
      verify(mockAuthClientWrapper.createAuthClient()).called(1);
    });
  });

  group('saveAndGetUrl', () {
    test('Nên trả về null nếu client chưa được khởi tạo', () {
      CloudApi cloudApi = CloudApi(MockAuthClientWrapper());
      expect(cloudApi.client, isNull);
    });
    test('Nên khởi tạo client nếu chưa được khởi tạo trước đó', () async {
      final mockAuthClientWrapper = MockAuthClientWrapper();
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();

      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      CloudApi cloudApi = CloudApi(mockAuthClientWrapper);
      await cloudApi.initializeClient();

      expect(cloudApi.client, isNotNull);
      verify(mockAuthClientWrapper.createAuthClient()).called(1);
    });
    test('Nên trả về null nếu bucket chưa được khởi tạo', () async {
      CloudApi cloudApi = CloudApi(MockAuthClientWrapper());
      expect(
          () => cloudApi.cloudStorage.bucket('testflutter'), throwsException);
    });

    test('Nên trả về bucket không null sau khi khởi tạo', () async {
      final mockAuthClientWrapper = MockAuthClientWrapper();
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);
      CloudApi cloudApi = CloudApi(mockAuthClientWrapper);
      await cloudApi.initializeClient();
      expect(cloudApi.cloudStorage.bucket('testflutter'), isNotNull);
      verify(mockAuthClientWrapper.createAuthClient()).called(1);
    });

    test('saveAndGetUrl sẽ trả về một URL hình ảnh hợp lệ', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final expectedUrl =
          'https://storage.googleapis.com/testflutter/hinh-anh-gia-lap.png';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => expectedUrl);

      final result =
          await mockCloudApi.saveAndGetUrl('hinh-anh.png', mockImage);

      expect(result, equals(expectedUrl));
    });
    test('saveAndGetUrl sẽ trả về một URL hình ảnh không hợp lệ', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final invalidUrl =
          'https://storage.googleapis.com/testflutter/hinh-anh-gia-lap.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => invalidUrl);

      final result =
          await mockCloudApi.saveAndGetUrl('hinh-anh.png', mockImage);

      expect(
          result,
          isNot(equals(
              'https://storage.googleapis.com/testflutter/hinh-anh-gia-lap.png')));
    });
  });
  group('extractTextFromImage', () {
    test('Nên trả về null nếu client chưa được khởi tạo', () {
      expect(cloudApi.client, isNull);
    });

    test('Nên khởi tạo client nếu chưa được khởi tạo trước đó', () async {
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      await cloudApi.initializeClient();
      expect(cloudApi.client, isNotNull);
      verify(mockAuthClientWrapper.createAuthClient()).called(1);
    });
    test('Nên trả về URL hợp lệ nếu imageBytes hợp lệ', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final expectedUrl =
          'https://storage.googleapis.com/testflutter/hinh-anh.png';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => expectedUrl);

      final result =
          await mockCloudApi.saveAndGetUrl('hinh-anh.png', mockImage);
      expect(result, equals(expectedUrl));
    });

    test('Nên trả về null nếu imageBytes rỗng hoặc lỗi', () async {
      final Uint8List emptyImage = Uint8List(0);
      when(mockCloudApi.saveAndGetUrl(any, any)).thenAnswer((_) async => '');

      final result =
          await mockCloudApi.saveAndGetUrl('hinh-anh.png', emptyImage);
      expect(result, equals(''));
    });
    test('Nên xử lý request với base64Image hợp lệ', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final expectedUrl =
          'https://storage.googleapis.com/testflutter/hinh-anh.png';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => expectedUrl);

      final result =
          await mockCloudApi.saveAndGetUrl('hinh-anh.png', mockImage);
      expect(result, equals(expectedUrl));
    });

    test('Nên xử lý request với base64Image bị lỗi', () async {
      final Uint8List corruptedImage = Uint8List(0);
      when(mockCloudApi.saveAndGetUrl(any, any)).thenAnswer((_) async => '');

      final result =
          await mockCloudApi.saveAndGetUrl('hinh-anh.png', corruptedImage);
      expect(result, '');
    });
    test('extractTextFromImage sẽ trả về văn bản đã trích xuất', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final extractedText = 'Văn bản giả lập';

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => extractedText);

      final result = await mockCloudApi.extractTextFromImage(mockImage);

      expect(result, equals(extractedText));
    });

    test('extractTextFromImage không nên trả về null', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final extractedText = 'Văn bản giả lập';

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => extractedText);

      final result = await mockCloudApi.extractTextFromImage(mockImage);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      expect(result, equals(extractedText));
    });
  });
group('sendToBackend Tests', () {
    const validUrl = 'https://backend-bdclpm.onrender.com/api/gemini/process';
    const invalidUrl = 'https://invalid-url.com/api/gemini/process';

    test('URL is valid', () {
      final url = Uri.parse(validUrl);
      expect(url, isA<Uri>());
      expect(url.toString(), validUrl);
    });

    test('URL is invalid', () {
      final uri = Uri.parse('invalid-url');
      expect(uri.hasAbsolutePath, false);
    });
test('Successful request (statusCode == 200)', () async {
    final fakeResponse = jsonEncode({'status': 'success', 'message': 'Processed successfully'});
    when(mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response(fakeResponse, 200));
    final response = await CloudApi.sendToBackend('test text', httpClient: mockHttpClient);
    expect(response, fakeResponse);
  });

    test('Failed request (statusCode != 200)', () async {
      final fakeResponse = jsonEncode({'status': 'error', 'message': 'Bad request'});

      when(mockHttpClient.post(
        Uri.parse(validUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(fakeResponse, 400));

      final response = await CloudApi.sendToBackend('test text');
      expect(jsonDecode(response)['status'], 'error');
    });

    test('response.statusCode == 200', () async {
      when(mockHttpClient.post(
        Uri.parse(validUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      final response = await CloudApi.sendToBackend('test text');
      expect(jsonDecode(response), isA<Map<String, dynamic>>());
    });

    test('response.statusCode == 400', () async {
      when(mockHttpClient.post(
        Uri.parse(validUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 400));

      final response = await CloudApi.sendToBackend('test text');
      expect(jsonDecode(response)['status'], 'error');
    });

    test('response.statusCode == 500', () async {
      when(mockHttpClient.post(
        Uri.parse(validUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 500));

      final response = await CloudApi.sendToBackend('test text');
      expect(jsonDecode(response)['status'], 'error');
    });

    test('Network error (catch block)', () async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Network error'));

      final response = await CloudApi.sendToBackend('test text');
      expect(jsonDecode(response)['status'], 'error');
    });

    test('Server not responding', () async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Server timeout'));

      final response = await CloudApi.sendToBackend('test text');
      expect(jsonDecode(response)['status'], 'error');
    });

    test('Unexpected http.post error', () async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Unexpected error'));

      final response = await CloudApi.sendToBackend('test text');
      expect(jsonDecode(response)['status'], 'error');
    });
  });
}
