import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ExpenseManager {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _category;
  List<dynamic> categories = [];
  bool isLoadingCategories = true;
  late stt.SpeechToText _speech;
  bool _isListeningForStoreName = false;
  bool _isListeningForAmount = false;
  bool _isListeningForDescription = false;
  bool _isListeningForDate = false;
  bool _enableVoiceInput = false;

  final Function(String) _showSnackBar;
  final Future<SharedPreferences> _sharedPreferences;
  final http.Client _httpClient;
  ExpenseManager(
    this._showSnackBar,
    this._sharedPreferences, {
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  TextEditingController get storeNameController => _storeNameController;
  TextEditingController get amountController => _amountController;
  TextEditingController get dateController => _dateController;
  TextEditingController get descriptionController => _descriptionController;
  String? get category => _category;
  bool get isListeningForStoreName => _isListeningForStoreName;
  bool get isListeningForAmount => _isListeningForAmount;
  bool get isListeningForDescription => _isListeningForDescription;
  bool get isListeningForDate => _isListeningForDate;
  bool get enableVoiceInput => _enableVoiceInput;

  void setCategory(String? category) {
    _category = category;
  }

  void setEnableVoiceInput(bool value) {
    _enableVoiceInput = value;
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('https://backend-bdclpm.onrender.com/api/categories'));
      if (response.statusCode == 200) {
        categories = json.decode(response.body);
        isLoadingCategories = false;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      isLoadingCategories = false;
    }
  }

  void updateDescription(String categoryName) {
    final category = categories.firstWhere(
      (category) => category['name'] == categoryName,
      orElse: () => {},
    );
    if (category.isNotEmpty && category.containsKey('description')) {
      _descriptionController.text = category['description'] ?? '';
    }
  }

  Future<void> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) {
      _showSnackBar(
          'Quyền micro chưa được cấp! Vui lòng cấp quyền trong cài đặt.');
    }
  }

  Future<void> startListening(
      TextEditingController controller, String field) async {
    await _checkMicrophonePermission();
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Trạng thái: $status');
      },
      onError: (error) {
        debugPrint('Lỗi: ${error.errorMsg}');
      },
    );
    if (available) {
      if (field == 'storeName') _isListeningForStoreName = true;
      if (field == 'amount') _isListeningForAmount = true;
      if (field == 'description') _isListeningForDescription = true;
      if (field == 'date') _isListeningForDate = true;
      debugPrint("Listening started for $field...");
      _speech.listen(
        onResult: (result) {
          debugPrint('Speech Result for $field: ${result.recognizedWords}');
          controller.text = result.recognizedWords;
        },
        pauseFor: const Duration(seconds: 5),
        listenFor: const Duration(seconds: 30),
        partialResults: true,
      );
    } else {
      debugPrint("Speech recognition not available.");
      _showSnackBar(
          'Không thể sử dụng ghi âm, vui lòng kiểm tra quyền hoặc thiết bị.');
    }
  }

  void _stopListening(String field) {
    if (field == 'storeName') _isListeningForStoreName = false;
    if (field == 'amount') _isListeningForAmount = false;
    if (field == 'description') _isListeningForDescription = false;
    if (field == 'date') _isListeningForDate = false;
    _speech.stop();
  }

  Future<void> saveExpense() async {
    try {
      final prefs = await _sharedPreferences;
      final userId = prefs.getString('userId');

      if (userId == null) {
        _showSnackBar('Không tìm thấy thông tin người dùng!');
        return;
      }

      final selectedCategoryId = categories.firstWhere(
        (category) => category['name'] == _category,
        orElse: () => null,
      )?['_id'];

      if (selectedCategoryId == null) {
        _showSnackBar('Vui lòng chọn danh mục hợp lệ!');
        return;
      }

      DateTime? parsedDate;
      try {
        parsedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
      } catch (e) {
        _showSnackBar(
            'Ngày không hợp lệ, vui lòng nhập đúng định dạng (dd/MM/yyyy)!');
        return;
      }

      final formattedDate = parsedDate.toIso8601String();

      final expenseData = {
        'userId': userId,
        'storeName': _storeNameController.text.trim(),
        'totalAmount': double.tryParse(_amountController.text) ?? 0,
        'date': formattedDate,
        'description': _descriptionController.text.trim(),
        'categoryId': selectedCategoryId,
      };

      final response = await http.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expenseData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Lưu chi tiêu thành công!');
      } else {
        _showSnackBar('Lỗi khi lưu chi tiêu: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Đã xảy ra lỗi: $e');
    }
  }

  void _saveExpense() {
    if (_storeNameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _category == null) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    saveExpense();
  }
}
