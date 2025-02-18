import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PdfExcelController extends ChangeNotifier{
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? category;
  List<dynamic> categories = [];
  bool isLoadingCategories = true;

  Future<void> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('https://backend-bdclpm.onrender.com/api/categories'));
      if (response.statusCode == 200) {
        categories = json.decode(response.body);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    } finally {
      isLoadingCategories = false;
      if (categories.isNotEmpty) {
        category = categories.first['name'];
      }
      if (categories.isNotEmpty) {
        category = categories.first['name'];
      }
    }
  }

  void updateDescription(String? categoryName) {
    final category = categories.firstWhere(
      (cat) => cat['name'] == categoryName,
      orElse: () => null,
    );
    if (category != null) {
      descriptionController.text = category['description'] ?? '';
    }
  }

  Future<void> pickPdfOrExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xls', 'xlsx'],
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        filePath.endsWith('.pdf')
            ? processPdfFile(filePath)
            : processExcelFile(filePath);
      } else {
        throw Exception("Không thể truy cập tệp.");
      }
    } else {
      throw Exception("Không có tệp nào được chọn.");
    }
  }

  String removeDiacritics(String text) {
    const accents = {
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
    };
    return text.split('').map((char) => accents[char] ?? char).join('');
  }

  String categorizeInvoice(String storeName) {
    List<String> foodKeywords = [
      'cơm',
      'mì',
      'phở',
      'bánh mì',
      'chè',
      'sữa chua'
    ];
    List<String> electronicsKeywords = ['laptop', 'phone', 'tv', 'máy tính'];
    List<String> serviceKeywords = [
      'dịch vụ',
      'spa',
      'thẩm mỹ',
      'trường',
      'đại học'
    ];
    List<String> clothingKeywords = ['áo', 'quần', 'váy', 'giày', 'túi'];
    List<String> transportationKeywords = [
      'vé',
      'xe',
      'tàu',
      'máy bay',
      'chuyến bay'
    ];

    List<String> foodStoreKeywords = [
      'siêu thị',
      'cửa hàng thực phẩm',
      'gian hàng thực phẩm'
    ];
    List<String> electronicsStoreKeywords = [
      'cửa hàng điện tử',
      'trung tâm điện tử',
      'máy tính'
    ];
    List<String> serviceStoreKeywords = [
      'dịch vụ',
      'spa',
      'thẩm mỹ viện',
      'trường',
      'đại học',
      'học phí'
    ];
    List<String> clothingStoreKeywords = [
      'shop quần áo',
      'thời trang',
      'shop giày dép'
    ];
    List<String> transportationStoreKeywords = [
      'vé tàu',
      'vé máy bay',
      'dịch vụ vận tải'
    ];

    final normalizedStoreName = removeDiacritics(storeName.toLowerCase());

    bool containsKeywords(List<String> keywords) {
      return keywords.any((kw) => normalizedStoreName.contains(kw));
    }

    if (containsKeywords(foodKeywords) || containsKeywords(foodStoreKeywords)) {
      return 'Thực phẩm';
    }
    if (containsKeywords(electronicsKeywords) ||
        containsKeywords(electronicsStoreKeywords)) {
      return 'Điện tử';
    }
    if (containsKeywords(serviceKeywords) ||
        containsKeywords(serviceStoreKeywords)) {
      return 'Dịch vụ';
    }
    if (containsKeywords(clothingKeywords) ||
        containsKeywords(clothingStoreKeywords)) {
      return 'Thời trang';
    }
    if (containsKeywords(transportationKeywords) ||
        containsKeywords(transportationStoreKeywords)) {
      return 'Vận chuyển';
    }

    return 'Khác';
  }

  Future<void> processPdfFile(String filePath) async {
    try {
      final document =
          PdfDocument(inputBytes: await File(filePath).readAsBytes());
      final extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      final storeName = extractStoreName(extractedText);
      final totalAmount = extractTotalAmount(extractedText);
      final date = extractDate(extractedText);

      storeNameController.text = storeName ?? "Không tìm thấy tên cửa hàng";
      amountController.text = totalAmount ?? "0";
      dateController.text = date ?? DateTime.now().toString();
      category = categorizeInvoice(storeName ?? "");
      descriptionController.text = "Trích xuất từ PDF";
    } catch (e) {
      throw Exception("Lỗi khi xử lý PDF: $e");
    }
  }

  String? extractStoreName(String text) {
    final patterns = [
      RegExp(r'^Công ty.*$', multiLine: true),
      RegExp(r'^TRƯỜNG.*$', multiLine: true),
      RegExp(r'^Nhà hàng.*$', multiLine: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(0)?.trim();
    }
    return null;
  }

  String? extractTotalAmount(String text) {
    final pattern = RegExp(r'(tổng cộng|total|tổng)\s*[:\-]?\s*([\d.,]+)',
        caseSensitive: false);
    final match = pattern.firstMatch(removeDiacritics(text));
    return match?.group(2)?.replaceAll(RegExp(r'[^\d]'), '');
  }

  String? extractDate(String text) {
    final match = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})').firstMatch(text);
    return match != null
        ? '${match.group(1)}/${match.group(2)}/${match.group(3)}'
        : null;
  }

  Future<void> processExcelFile(String filePath) async {
    try {
      final excel = Excel.decodeBytes(await File(filePath).readAsBytesSync());
      final rows = excel.tables.values.first.rows;

      if (rows.isNotEmpty) {
        storeNameController.text = rows[0][0]?.value?.toString() ?? "";
        amountController.text = rows[0][1]?.value?.toString() ?? "0";
        dateController.text = rows[0][2]?.value?.toString() ?? "";
        category = rows[0][3]?.value?.toString() ?? "Khác";
        descriptionController.text = rows[0][4]?.value?.toString() ?? "";
      }
    } catch (e) {
      throw Exception("Lỗi khi xử lý Excel: $e");
    }
  }

  Future<void> saveExpense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null)
        throw Exception('Không tìm thấy thông tin người dùng');

      final selectedCategoryId =
          categories.firstWhere((cat) => cat['name'] == category)?['_id'];
      if (selectedCategoryId == null) throw Exception('Danh mục không hợp lệ');

      final isIso8601 =
          RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateController.text);

      String formattedDate;

      if (isIso8601) {
        formattedDate = dateController.text;
      } else {
        final parsedDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
        formattedDate = parsedDate.toIso8601String();
      }

      final expenseData = {
        'userId': userId,
        'storeName': storeNameController.text.trim(),
        'totalAmount': double.tryParse(amountController.text) ?? 0,
        'date': formattedDate,
        'description': descriptionController.text.trim(),
        'categoryId': selectedCategoryId,
      };

      final response = await http.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expenseData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Lỗi khi lưu chi tiêu: ${response.body}');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
}
