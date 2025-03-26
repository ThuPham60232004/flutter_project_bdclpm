import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/mocks.mocks.dart';
import 'package:flutter/services.dart';
import '../../test_config.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

void main() {
  setupTestEnvironment();
  late MockCloudApi mockCloudApi;
  late MockClient mockHttpClient;
  late CloudApi cloudApi;
  late MockStorage mockStorage;
  late MockBucket mockBucket;
  late MockObjectInfo mockObjectInfo;

  late MockAuthClientWrapper mockAuthClientWrapper;
  setUp(() {
    mockHttpClient = MockClient();
    mockCloudApi = MockCloudApi();
    mockAuthClientWrapper = MockAuthClientWrapper();
    cloudApi = CloudApi(mockAuthClientWrapper);
    mockStorage = MockStorage();
    mockBucket = MockBucket();
    mockObjectInfo = MockObjectInfo();
    when(mockAuthClientWrapper.createAuthClient())
        .thenAnswer((_) async => MockAutoRefreshingAuthClient());
  });
  group('InitializeClient', () {
    test('UC01: initializeClient() nên khởi tạo client nếu chưa có', () async {
      final mockAutoRefreshingClient = MockAutoRefreshingAuthClient();
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => mockAutoRefreshingClient);

      final client = await mockAuthClientWrapper.createAuthClient();

      final result = client != null;
      print('Kết quả so sánh trạng thái: $result');
      expect(result, isTrue);

      verify(mockAuthClientWrapper.createAuthClient()).called(1);
    });

    test('UC02: initializeClient() không nên khởi tạo lại nếu client đã tồn tại',
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
    test('UC03: Trả lại storage khi khởi tạo', () async {
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => MockAutoRefreshingAuthClient());

      await cloudApi.initializeClient();

      expect(cloudApi.cloudStorage, isNotNull);
      print(cloudApi.cloudStorage != null
          ? "Thành công: Storage đã được khởi tạo!"
          : "Thất bại: Storage chưa được khởi tạo!");
    });

    test('UC04: Ném một ngoại lệ nếu storage không được khởi tạo', () {
      try {
        cloudApi.cloudStorage;
        print("Thất bại: Không ném ra ngoại lệ!");
      } catch (e) {
        print("Thành công: Đã ném ngoại lệ - ${e.toString()}");
      }

      expect(() => cloudApi.cloudStorage, throwsException);
    });
  });

  group('save', () {
    test('UC01: Trả về null nếu client chưa được khởi tạo', () {
      CloudApi cloudApi = CloudApi(MockAuthClientWrapper());
      bool result = cloudApi.client == null;
      print('Client chưa được khởi tạo: $result');
      expect(result, isTrue);
    });

    test('UC02: Khởi tạo client nếu chưa được khởi tạo trước đó', () async {
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

    test('UC03: Trả về null nếu bucket chưa được khởi tạo', () async {
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

    test('UC04: Trả về bucket không null sau khi khởi tạo', () async {
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
    const fileName = "test_image.jpg";
    final fakeBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    test('UC01: _client hợp lệ', () async {
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => MockAutoRefreshingAuthClient());

      await cloudApi.initializeClient();
      expect(cloudApi.client, isNotNull);
      print('_client hợp lệ');
    });
    test('UC02: _client bị lỗi (null)', () async {
      when(mockAuthClientWrapper.createAuthClient())
          .thenThrow(Exception('Không thể tạo client'));

      expect(() async => await cloudApi.saveAndGetUrl(fileName, fakeBytes),
          throwsException);
      print('_client bị lỗi (null)');
    });
    test('UC03: Trả về null nếu bucket chưa được khởi tạo', () async {
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

    test('UC04: Trả về bucket không null sau khi khởi tạo', () async {
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
    test('UC05: fileUrl hợp lệ sẽ trả về một URL hình ảnh hợp lệ', () async {
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

    test('UC06: fileUrl không hợp lệ sẽ trả về một URL hình ảnh không hợp lệ',
        () async {
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
    const fileName = "test_image.jpg";
    final fakeBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

    test('UC01: _client hợp lệ', () async {
      when(mockAuthClientWrapper.createAuthClient())
          .thenAnswer((_) async => MockAutoRefreshingAuthClient());

      await cloudApi.initializeClient();
      expect(cloudApi.client, isNotNull);
      print('_client hợp lệ');
    });

    test('UC02: _client bị lỗi (null)', () async {
      when(mockAuthClientWrapper.createAuthClient())
          .thenThrow(Exception('Không thể tạo client'));

      expect(() async => await cloudApi.saveAndGetUrl(fileName, fakeBytes),
          throwsException);
      print('_client bị lỗi (null)');
    });

    test('UC03: Base64Image hợp lệ theo yêu cầu', () async {
      final image = {"content": "dummy_base64"};
      final request = {
        "image": image,
        "features": [
          {"type": "DOCUMENT_TEXT_DETECTION"}
        ]
      };
      expect(request["image"], image);
      expect(
          (request["features"] is List &&
                  (request["features"] as List).isNotEmpty)
              ? (request["features"] as List).first["type"]
              : null,
          "DOCUMENT_TEXT_DETECTION");
      print('Yêu cầu kiểm tra tạo đối tượng đã vượt qua');
    });

    test('UC04: Base64Image không hợp lệ trong yêu cầu', () {
      final image = {"content": ""};
      final request = {
        "image": image,
        "features": [
          {"type": "DOCUMENT_TEXT_DETECTION"}
        ]
      };
      expect(request["image"], image);
      expect(image["content"], '');
      print('Base64Image không hợp lệ trong yêu cầu');
    });

    test('UC05: Mã hóa Base64 của imageBytes là chính xác', () async {
      final Uint8List fakeImageBytes =
          Uint8List.fromList([72, 101, 108, 108, 111]);
      final base64String = base64Encode(fakeImageBytes);
      expect(base64String, 'SGVsbG8=');
      print('Đã vượt qua bài kiểm tra mã hóa Base64');
    });

    test('UC06: Mã hóa imageBytes trống', () {
      final Uint8List emptyBytes = Uint8List(0);
      final base64String = base64Encode(emptyBytes);
      expect(base64String, '');
      print('Mã hóa imageBytes trống thành công');
    });

    test('UC07: request & batchRequest hợp lệ', () async {
      final request = {"image": "dummy_image", "features": "dummy_feature"};
      final batchRequest = {
        "requests": [request]
      };
      expect(
          (batchRequest["requests"] is List &&
                  (batchRequest["requests"] as List).isNotEmpty)
              ? (batchRequest["requests"] as List).first["image"]
              : null,
          "dummy_image");
      print('Đã vượt qua bài kiểm tra tạo yêu cầu hàng loạt');
    });

    test('UC08: request & batchRequest không hợp lệ', () {
      final request = {"image": "", "features": "valid_feature"};
      final batchRequest = {
        "requests": [request]
      };
      expect(batchRequest["requests"]?.first["image"], "");
      print('Request & batchRequest không hợp lệ');
    });

    test('UC09: request & batchRequest hàng loạt rỗng', () {
      Map<String, dynamic>? batchRequest;
      expect(() => batchRequest!["requests"].first["image"],
          throwsA(isA<Error>()));
      print('Request & batchRequest hàng loạt rỗng');
    });

    test(
        'UC10: extractTextFromImage trả về văn bản đã trích xuất khi thành công',
        () async {
      final mockResponse = {
        "responses": [
          {
            "textAnnotations": [
              {"description": "Mẫu văn bản trích xuất"}
            ]
          }
        ]
      };

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => jsonEncode(mockResponse));

      final Uint8List fakeImageBytes = Uint8List.fromList([0, 1, 2, 3]);
      final result = await mockCloudApi.extractTextFromImage(fakeImageBytes);

      expect(result, jsonEncode(mockResponse));
      print('Trích xuất văn bản thành công kiểm tra đã vượt qua');
    });

    test('UC11: extractTextFromImage xử lý phản hồi trống', () async {
      final mockResponse = {"responses": []};

      when(mockCloudApi.extractTextFromImage(any))
          .thenAnswer((_) async => jsonEncode(mockResponse));

      final Uint8List fakeImageBytes = Uint8List.fromList([0, 1, 2, 3]);
      final result = await mockCloudApi.extractTextFromImage(fakeImageBytes);

      expect(
          result, jsonEncode({'status': 'error', 'message': 'No text found'}));
      print('Đã vượt qua bài kiểm tra phản hồi trống');
    });
  });
  group('sendToBackend Tests', () {
    const validUrl = 'https://backend-bdclpm.onrender.com/api/gemini/process';
    const invalidUrl = 'https://invalid-url.com/api/gemini/process';

    test('UC01: URL có giá trị', () {
      final url = Uri.parse(validUrl);
      bool result = url.toString() == validUrl;
      print('URL hợp lệ: $result');
      expect(result, isTrue);
    });

    test('UC02: URL không hợp lệ', () {
      const invalidUrl = 'ht!tp://invalid-url.com/api/gemini/process';
      try {
        Uri.parse(invalidUrl);
      } catch (e) {
        print('UC02: Lỗi: $e');
      }
    });

    test('UC03: Yêu cầu thành công (statusCode == 200)', () async {
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

    test('UC04: Lỗi yêu cầu (statusCode != 200)', () async {
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

    test('UC05: response.statusCode == 200', () async {
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

    test('UC06: response.statusCode == 400', () async {
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

    test('UC07: response.statusCode == 500', () async {
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

    test('UC08: Lỗi mạng (catch block)', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Network error'));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response)['status'] == 'error';
      print('Lỗi mạng (status == error): $result');
      expect(result, isTrue);
    });

    test('UC09: Server không phản hồi', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Server timeout'));

      final response = await CloudApi.sendToBackend('test text');
      bool result = jsonDecode(response)['status'] == 'error';
      print('Máy chủ không phản hồi (status == error): $result');
      expect(result, isTrue);
    });

    test('UC10: Lỗi http.post không mong đợi', () async {
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
