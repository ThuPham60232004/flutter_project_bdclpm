import 'dart:typed_data';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:gcloud/storage.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
class CloudApi {
  final auth.ServiceAccountCredentials _credentials;
  auth.AutoRefreshingAuthClient? _client;

  // Constructor to initialize the credentials
  CloudApi(String json) : _credentials = auth.ServiceAccountCredentials.fromJson(json);

  // Ensure client initialization with the correct scopes
  Future<void> _initializeClient() async {
    _client ??= await auth.clientViaServiceAccount(
      _credentials,
      [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/cloud-vision',
      ], // Add required scopes here
    );
  }

  // Function to save image to Google Cloud Storage
  Future<ObjectInfo> save(String name, Uint8List imgBytes) async {
    await _initializeClient();  // Ensure the client is initialized

    var storage = Storage(_client!, 'testflutter');  // Replace with your bucket name
    var bucket = storage.bucket('testflutter');  // Replace with your bucket name

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Lookup MIME type based on the file extension
    final type = lookupMimeType(name);

    // Write the image bytes to the cloud storage bucket
    return await bucket.writeBytes(name, imgBytes,
        metadata: ObjectMetadata(
          contentType: type,
          custom: {'timestamp': '$timestamp'},
        ));
  }

  Future<String> extractTextFromImage(Uint8List imageBytes) async {
  await _initializeClient();  // Ensure the client is initialized

  // Convert Uint8List to base64 string
  String base64Image = base64Encode(imageBytes);

  // Initialize the Vision API client
  var visionApi = vision.VisionApi(_client!);

  // Create the image annotation request
  var image = vision.Image(content: base64Image);  // Pass base64 encoded string
  var request = vision.AnnotateImageRequest(
    image: image,
    features: [vision.Feature(type: 'DOCUMENT_TEXT_DETECTION')],  // Detect document text
  );

  var batchRequest = vision.BatchAnnotateImagesRequest(requests: [request]);

  try {
    var batchResponse = await visionApi.images.annotate(batchRequest);
    
    // Check if the response has text annotations
    if (batchResponse.responses != null && batchResponse.responses!.isNotEmpty) {
      var response = batchResponse.responses!.first;
      
      if (response.textAnnotations != null && response.textAnnotations!.isNotEmpty) {
        var text = response.textAnnotations!.first.description ?? 'No text found';
        print('Extracted Text: $text');  // Log the extracted text for debugging

        // Return the full response as JSON
        return jsonEncode({
          'status': 'success',
          'text': text,
          'fullResponse': batchResponse.toJson(),
        });
      } else {
        print('No text annotations found in the image.');
        return jsonEncode({
          'status': 'error',
          'message': 'No text found',
        });
      }
    } else {
      print('No responses returned from Vision API.');
      return jsonEncode({
        'status': 'error',
        'message': 'No text found',
      });
    }
  } catch (e) {
    print('Error while extracting text: $e');
    return jsonEncode({
      'status': 'error',
      'message': 'Error extracting text: $e',
    });
  }
}

}
