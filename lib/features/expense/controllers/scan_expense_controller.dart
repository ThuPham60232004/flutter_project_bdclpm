import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';

class ScanExpenseController {
  String? userId;
  File? image;
  Uint8List? imageBytes;
  String? imageName;
  String extractedText = '';
  bool isUploaded = false;
  bool loading = false;
  String? imageUrl;

  final picker = ImagePicker();

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  String convertToIsoDate(String date) {
    try {
      DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(date);
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return date;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        image = File(pickedFile.path);
        imageBytes = image?.readAsBytesSync();
        imageName = image?.path.split('/').last;
        isUploaded = false;
        extractedText = '';
      }
    } catch (e) {
      throw Exception('Error selecting image: $e');
    }
  }

  Future<void> saveImage(CloudApi api) async {
    if (imageBytes == null || imageName == null) {
      throw Exception('Please select an image before uploading.');
    }

    loading = true;

    try {
      imageUrl = await api.saveAndGetUrl(imageName!, imageBytes!);
      isUploaded = true;
    } catch (e) {
      throw Exception('Error uploading image: $e');
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
      throw Exception('Error extracting text: $e');
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

    final response = await http.post(
      Uri.parse("https://backend-bdclpm.onrender.com/api/expenses"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(expenseData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create expense: ${response.body}');
    }
  }

  String formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'vi_VN');
    return formatter.format(amount);
  }
}
