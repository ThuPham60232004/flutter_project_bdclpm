import 'dart:typed_data';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:gcloud/storage.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../data/auth_client_wrapper.dart';
class CloudApi {
final AuthClientWrapper authClientWrapper;
  auth.AutoRefreshingAuthClient? client;
  Storage? storage;
  String bucketName = 'testflutter';
  int? timestamp;
  CloudApi(this.authClientWrapper);

   Future<void> initializeClient() async {
    if (authClientWrapper == null) {
      throw Exception("AuthClientWrapper is required");
    }
    client = await authClientWrapper!.createAuthClient();
    storage = Storage(client!, bucketName);
  }

  Storage get cloudStorage {
    if (storage == null) {
      throw Exception("Cloud storage not initialized");
    }
    return storage!;
  }


  Future<ObjectInfo> save(String name, Uint8List imgBytes) async {
    await initializeClient();

    var bucket = cloudStorage.bucket(bucketName);

    timestamp = DateTime.now().millisecondsSinceEpoch;
    final type = lookupMimeType(name);

    return await bucket.writeBytes(name, imgBytes,
        metadata: ObjectMetadata(
          contentType: type,
          custom: {'timestamp': '$timestamp'},
        ));
  }

  Future<String> saveAndGetUrl(String name, Uint8List imgBytes) async {
    await initializeClient();

    var storage = Storage(client!, 'testflutter');
    var bucket = storage.bucket('testflutter');

    timestamp = DateTime.now().millisecondsSinceEpoch;
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
    await initializeClient();

    String base64Image = base64Encode(imageBytes);

    var visionApi = vision.VisionApi(client!);

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
          var backendResponse = await sendToBackend(text);

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



 static Future<String> sendToBackend(String extractedText, {http.Client? httpClient}) async {
  final url = Uri.parse('https://backend-bdclpm.onrender.com/api/gemini/process');
  httpClient ??= http.Client();

  try {
    final response = await httpClient.post(
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
  } finally {
    httpClient.close();
  }
}

}
