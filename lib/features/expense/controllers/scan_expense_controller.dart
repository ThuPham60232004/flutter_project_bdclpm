import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:flutter/foundation.dart';
class ScanExpenseController {
  String? userId;
  File? image;
  Uint8List? imageBytes;
  String? imageName;
  String extractedText = '';
  bool isUploaded = false;
  bool loading = false;
  String? imageUrl;
  final http.Client httpClient;
  final ImagePicker picker = ImagePicker();

  ScanExpenseController({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<void> loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
    } catch (e) {
      throw Exception('Lỗi khi tải userId: $e');
    }
  }

  String convertToIsoDate(String date) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      return date;
    }
    try {
      DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(date);
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      throw Exception("Invalid date format: $date");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        image = File(pickedFile.path);
        imageBytes = await pickedFile.readAsBytes();
        imageName = pickedFile.path.split('/').last;
        isUploaded = false;
        extractedText = '';
      }
    } catch (e) {
      throw Exception('Error selecting image: $e');
    }
  }

  Future<void> saveImage(CloudApi api) async {
  if (imageBytes == null || imageName == null) {
    debugPrint('[ERROR] Image not selected');
    throw Exception('Vui lòng chọn ảnh trước khi tải lên');
  }

  loading = true;
  try {
    debugPrint('[UPLOAD] Starting upload: $imageName');
    debugPrint('[DEBUG] Image size: ${imageBytes!.length} bytes');
    
    imageUrl = await api.saveAndGetUrl(imageName!, imageBytes!);
    isUploaded = true;
    
    debugPrint('[SUCCESS] Image uploaded to: $imageUrl');
  } catch (e, stackTrace) {
    debugPrint('[ERROR] Upload failed: ${e.toString()}');
    debugPrint('[STACKTRACE] ${stackTrace.toString()}');
    throw Exception('Tải ảnh lên thất bại: ${e.toString().replaceAll('SERVER_ERROR:', '')}');
  } finally {
    loading = false;
  }
}

  Future<void> extractText(CloudApi api) async {
    if (imageBytes == null) {
      throw Exception('No image selected for text extraction.');
    }

    loading = true;
    try {
      final resultJson = await api.extractTextFromImage(imageBytes!);
      extractedText =
          const JsonEncoder.withIndent("  ").convert(json.decode(resultJson));
    } catch (e) {
      throw Exception('Error extracting text: ${e.toString()}');
    } finally {
      loading = false;
    }
  }

  Future<void> createExpense({
    required String storeName,
    required double totalAmount,
    required String description,
    required String date,
    required String categoryId,
  }) async {
    if (userId == null) {
      throw Exception('User ID is not available.');
    }

    final expenseData = {
      "userId": userId,
      "storeName": storeName,
      "totalAmount": totalAmount,
      "description": description,
      "date": convertToIsoDate(date),
      "categoryId": categoryId,
    };

    try {
      final response = await httpClient.post(
        Uri.parse("https://backend-bdclpm.onrender.com/api/expenses"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(expenseData),
      );

      if (response.statusCode != 201) {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            'Failed to create expense: ${errorResponse["message"] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error creating expense: ${e.toString()}');
    }
  }

  String formatCurrency(double amount) {
     if (amount.isNaN || amount.isInfinite) {
    throw FormatException("Invalid amount");
  }
    final NumberFormat formatter = NumberFormat("#,##0", "vi_VN");
    return formatter.format(amount);
  }
}
