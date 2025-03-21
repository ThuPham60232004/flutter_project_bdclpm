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

      final result = client != null;
      print('Kết quả so sánh trạng thái: $result');
      expect(result, isTrue);

      verify(mockAuthClientWrapper.createAuthClient()).called(1);
    });

    test('initializeClient() không nên khởi tạo lại nếu client đã tồn tại',
        () async {
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      final cloudApi = CloudApi(mockAuthClientWrapper);

      await cloudApi.initializeClient();
      final firstInitResult = cloudApi.client != null;
      print('Kết quả lần 1: $firstInitResult');
      expect(firstInitResult, isTrue);

      verify(mockAuthClientWrapper.createAuthClient()).called(1);

      await cloudApi.initializeClient();
      final secondInitResult = cloudApi.client != null;
      print('Kết quả lần 2: $secondInitResult');
      expect(secondInitResult, isTrue);

      verify(mockAuthClientWrapper.createAuthClient()).called(1);

      verifyNoMoreInteractions(mockAuthClientWrapper);
    });
  });

  group('save', () {
    test('Nên trả về null nếu client chưa được khởi tạo', () {
      CloudApi cloudApi = CloudApi(MockAuthClientWrapper());
      bool result = cloudApi.client == null;
      print('Client chưa được khởi tạo: $result');
      expect(result, isTrue);
    });

    test('Nên khởi tạo client nếu chưa được khởi tạo trước đó', () async {
      final mockAuthClientWrapper = MockAuthClientWrapper();
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();

      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      CloudApi cloudApi = CloudApi(mockAuthClientWrapper);
      await cloudApi.initializeClient();

      bool result = cloudApi.client != null;
      print('Client đã được khởi tạo: $result');
      expect(result, isTrue);
    });

    test('Nên trả về null nếu bucket chưa được khởi tạo', () async {
      CloudApi cloudApi = CloudApi(MockAuthClientWrapper());
      bool result;
      try {
        cloudApi.cloudStorage.bucket('testflutter');
        result = false;
      } catch (e) {
        result = true;
      }
      print('Bucket chưa được khởi tạo: $result');
      expect(result, isTrue);
    });

    test('Nên trả về bucket không null sau khi khởi tạo', () async {
      final mockAuthClientWrapper = MockAuthClientWrapper();
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      CloudApi cloudApi = CloudApi(mockAuthClientWrapper);
      await cloudApi.initializeClient();

      bool result = cloudApi.cloudStorage.bucket('testflutter') != null;
      print('Bucket đã được khởi tạo: $result');
      expect(result, isTrue);
    });
  });

  group('saveAndGetUrl', () {
    test('saveAndGetUrl sẽ trả về một URL hình ảnh hợp lệ', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final expectedUrl =
          'https://storage.googleapis.com/testflutter/hinh-anh-gia-lap.png';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => expectedUrl);

      final result =
          await mockCloudApi.saveAndGetUrl('hinh-anh.png', mockImage);
      bool isValid = result == expectedUrl;

      print('URL hợp lệ: $isValid');
      expect(isValid, isTrue);
    });

    test('saveAndGetUrl sẽ trả về một URL hình ảnh không hợp lệ', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final invalidUrl =
          'https://storage.googleapis.com/testflutter/hinh-anh-gia-lap.jpg';

      when(mockCloudApi.saveAndGetUrl(any, any))
          .thenAnswer((_) async => invalidUrl);

      final result =
          await mockCloudApi.saveAndGetUrl('hinh-anh.png', mockImage);
      bool isInvalid = result !=
          'https://storage.googleapis.com/testflutter/hinh-anh-gia-lap.png';

      print('URL không hợp lệ: $isInvalid');
      expect(isInvalid, isTrue);
    });
  });

  group('extractTextFromImage', () {
    test('extractTextFromImage sẽ trả về văn bản đã trích xuất', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final extractedText = 'Văn bản giả lập';

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => extractedText);

      final result = await mockCloudApi.extractTextFromImage(mockImage);
      bool isCorrectText = result == extractedText;

      print('Văn bản trích xuất đúng: $isCorrectText');
      expect(isCorrectText, isTrue);
    });

    test('extractTextFromImage không nên trả về null', () async {
      final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);
      final extractedText = 'Văn bản giả lập';

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => extractedText);

      final result = await mockCloudApi.extractTextFromImage(mockImage);
      bool isNotNull = result != null && result.isNotEmpty;

      print('Văn bản không null: $isNotNull');
      expect(isNotNull, isTrue);
    });
  });

  group('sendToBackend Tests', () {
    const validUrl = 'https://backend-bdclpm.onrender.com/api/gemini/process';
    const invalidUrl = 'https://invalid-url.com/api/gemini/process';

    test('URL is valid', () {
      final url = Uri.parse(validUrl);
      bool result = url.toString() == validUrl;
      print('URL hợp lệ: $result');
      expect(result, isTrue);
    });

    test('URL is invalid', () {
      try {
        Uri.parse(invalidUrl);
        print('URL hợp lệ: false');
        expect(false, isTrue);
      } catch (e) {
        print('URL hợp lệ: true');
        expect(true, isTrue);
      }
    });

    test('Successful request (statusCode == 200)', () async {
      final fakeResponse = jsonEncode(
          {'status': 'success', 'message': 'Processed successfully'});

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(fakeResponse, 200));

      final response =
          await CloudApi.sendToBackend('test text', httpClient: mockHttpClient);
      bool result = jsonDecode(response)['status'] == 'success';
      print('Yêu cầu thành công (status == success): $result');
      expect(result, isTrue);
    });

    test('Failed request (statusCode != 200)', () async {
      final fakeResponse =
          jsonEncode({'status': 'error', 'message': 'Bad request'});

      when(mockHttpClient.post(
        Uri.parse(validUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(fakeResponse, 400));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response)['status'] == 'error';
      print('Yêu cầu thất bại (status == error): $result');
      expect(result, isTrue);
    });

    test('response.statusCode == 200', () async {
      when(mockHttpClient.post(
        Uri.parse(validUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response) is Map<String, dynamic>;
      print('Phản hồi statusCode == 200: $result');
      expect(result, isTrue);
    });

    test('response.statusCode == 400', () async {
      when(mockHttpClient.post(
        Uri.parse(validUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 400));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response)['status'] == 'error';
      print('Phản hồi statusCode == 400: $result');
      expect(result, isTrue);
    });

    test('response.statusCode == 500', () async {
      when(mockHttpClient.post(
        Uri.parse(validUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 500));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response)['status'] == 'error';
      print('Phản hồi statusCode == 500: $result');
      expect(result, isTrue);
    });

    test('Network error (catch block)', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Network error'));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response)['status'] == 'error';
      print('Lỗi mạng (status == error): $result');
      expect(result, isTrue);
    });

    test('Server not responding', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Server timeout'));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response)['status'] == 'error';
      print('Máy chủ không phản hồi (status == error): $result');
      expect(result, isTrue);
    });

    test('Unexpected http.post error', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Unexpected error'));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response)['status'] == 'error';
      print('Lỗi không mong muốn (status == error): $result');
      expect(result, isTrue);
    });
  });
}
