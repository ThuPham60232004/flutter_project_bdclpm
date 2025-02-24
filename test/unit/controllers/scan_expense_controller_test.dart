import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/mocks.mocks.dart';
import 'dart:typed_data';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:http/http.dart' as http;

void main() {
  late MockCloudApi mockCloudApi;
  late MockClient mockHttpClient;

  setUp(() {
    mockCloudApi = MockCloudApi();
    mockHttpClient = MockClient();
  });

  test('Lưu ảnh và trả về URL', () async {
    final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);

    when(mockCloudApi.saveAndGetUrl(any, any)).thenAnswer((_) async =>
        'https://storage.googleapis.com/testflutter/hinh-anh-gia-lap.png');

    final result = await mockCloudApi.saveAndGetUrl('hinh-anh.png', mockImage);

    expect(result, contains('hinh-anh-gia-lap.png'));
  });

  test('Trích xuất văn bản từ ảnh', () async {
    final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);

    when(mockCloudApi.extractTextFromImage(any))
        .thenAnswer((_) async => 'Văn bản giả lập');

    final result = await mockCloudApi.extractTextFromImage(mockImage);

    expect(result, contains('Văn bản giả lập'));
  });

  test('Trích xuất văn bản từ ảnh không trả về null', () async {
    final Uint8List mockImage = Uint8List.fromList([0, 1, 2, 3]);

    when(mockCloudApi.extractTextFromImage(any))
        .thenAnswer((_) async => 'Văn bản giả lập');

    final result = await mockCloudApi.extractTextFromImage(mockImage);

    expect(result, isNotNull);
    expect(result, contains('Văn bản giả lập'));
  });
}
