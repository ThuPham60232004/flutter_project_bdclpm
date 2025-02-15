import 'dart:typed_data';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:gcloud/storage.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CloudApi {
  final auth.ServiceAccountCredentials _credentials;
  auth.AutoRefreshingAuthClient? _client;

  CloudApi(String json)
      : _credentials = auth.ServiceAccountCredentials.fromJson(json);

  Future<void> _initializeClient() async {
    _client ??= await auth.clientViaServiceAccount(
      _credentials,
      [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/cloud-vision',
      ],
    );
  }

  Future<ObjectInfo> save(String name, Uint8List imgBytes) async {
    await _initializeClient();

    var storage = Storage(_client!, 'testflutter');
    var bucket = storage.bucket('testflutter');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final type = lookupMimeType(name);

    return await bucket.writeBytes(name, imgBytes,
        metadata: ObjectMetadata(
          contentType: type,
          custom: {'timestamp': '$timestamp'},
        ));
  }

  Future<String> saveAndGetUrl(String name, Uint8List imgBytes) async {
    await _initializeClient();

    var storage = Storage(_client!, 'testflutter');
    var bucket = storage.bucket('testflutter');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final type = lookupMimeType(name);

    final objectInfo = await bucket.writeBytes(name, imgBytes,
        metadata: ObjectMetadata(
          contentType: type,
          custom: {'timestamp': '$timestamp'},
        ));

    final fileUrl =
        'https://storage.googleapis.com/testflutter/${objectInfo.name}';
    return fileUrl;
  }

  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    await _initializeClient();

    String base64Image = base64Encode(imageBytes);

    var visionApi = vision.VisionApi(_client!);

    var image = vision.Image(content: base64Image);
    var request = vision.AnnotateImageRequest(
      image: image,
      features: [vision.Feature(type: 'DOCUMENT_TEXT_DETECTION')],
    );

    var batchRequest = vision.BatchAnnotateImagesRequest(requests: [request]);

    try {
      var batchResponse = await visionApi.images.annotate(batchRequest);

      if (batchResponse.responses != null &&
          batchResponse.responses!.isNotEmpty) {
        var response = batchResponse.responses!.first;

        if (response.textAnnotations != null &&
            response.textAnnotations!.isNotEmpty) {
          var text =
              response.textAnnotations!.first.description ?? 'No text found';

          // Gửi dữ liệu đến backend
          var backendResponse = await _sendToBackend(text);

          return backendResponse;
        } else {
          return jsonEncode({
            'status': 'error',
            'message': 'No text found',
          });
        }
      } else {
        return jsonEncode({
          'status': 'error',
          'message': 'No text found',
        });
      }
    } catch (e) {
      return jsonEncode({
        'status': 'error',
        'message': 'Error extracting text: $e',
      });
    }
  }

  Future<String> _sendToBackend(String extractedText) async {
    final url =
        Uri.parse('https://backend-bdclpm.onrender.com/api/gemini/process');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'extractedText': extractedText}),
      );

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return jsonEncode({
          'status': 'error',
          'message': 'Failed to process data on backend',
          'response': response.body,
        });
      }
    } catch (e) {
      return jsonEncode({
        'status': 'error',
        'message': 'Error sending data to backend: $e',
      });
    }
  }
}
