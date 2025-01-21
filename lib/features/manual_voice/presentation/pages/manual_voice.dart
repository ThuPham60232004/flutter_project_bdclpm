import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualVoicePage extends StatefulWidget {
  @override
  _ManualVoicePageState createState() => _ManualVoicePageState();
}

class _ManualVoicePageState extends State<ManualVoicePage> {
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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    fetchCategories(); 
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://backend-bdclpm.onrender.com/api/categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);  
          isLoadingCategories = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() {
        isLoadingCategories = false;
      });
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
      _showSnackBar('Quyền micro chưa được cấp! Vui lòng cấp quyền trong cài đặt.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _startListening(TextEditingController controller, String field) async {
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
      setState(() {
        if (field == 'storeName') _isListeningForStoreName = true;
        if (field == 'amount') _isListeningForAmount = true;
        if (field == 'description') _isListeningForDescription = true;
        if (field == 'date') _isListeningForDate = true;
      });
      debugPrint("Listening started for $field...");
      _speech.listen(
        onResult: (result) {
          debugPrint('Speech Result for $field: ${result.recognizedWords}');
          setState(() {
            controller.text = result.recognizedWords;
          });
        },
        pauseFor: const Duration(seconds: 5),
        listenFor: const Duration(seconds: 30), // Listening duration
        partialResults: true,
      );
    } else {
      debugPrint("Speech recognition not available.");
      _showSnackBar('Không thể sử dụng ghi âm, vui lòng kiểm tra quyền hoặc thiết bị.');
    }
  }

  void _stopListening(String field) {
    setState(() {
      if (field == 'storeName') _isListeningForStoreName = false;
      if (field == 'amount') _isListeningForAmount = false;
      if (field == 'description') _isListeningForDescription = false;
      if (field == 'date') _isListeningForDate = false;
    });
    _speech.stop();
  }

  Future<void> saveExpense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy thông tin người dùng!')),
        );
        return;
      }

      final selectedCategoryId = categories.firstWhere(
        (category) => category['name'] == _category, // Use the _category field selected from the dropdown
        orElse: () => null,
      )?['_id'];

      if (selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn danh mục hợp lệ!')),
        );
        return;
      }

      DateTime? parsedDate;
      try {
        parsedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ngày không hợp lệ, vui lòng nhập đúng định dạng (dd/MM/yyyy)!')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu chi tiêu thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu chi tiêu: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm chi tiêu'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn muốn nhập chi tiêu như thế nào?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text("Nhập thủ công"),
              value: !_enableVoiceInput,
              onChanged: (value) {
                setState(() {
                  _enableVoiceInput = !value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text("Quét hóa đơn"),
              value: false,
              onChanged: null,
            ),
            CheckboxListTile(
              title: const Text("Quét PDF/Excel"),
              value: false,
              onChanged: null,
            ),
            CheckboxListTile(
              title: const Text("Nhận dạng giọng nói"),
              value: _enableVoiceInput,
              onChanged: (value) {
                setState(() {
                  _enableVoiceInput = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _storeNameController,
              label: 'Tên cửa hàng',
              field: 'storeName',
              isVoiceInput: _enableVoiceInput,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _amountController,
              label: 'Số tiền',
              prefixText: 'VND ',
              keyboardType: TextInputType.number,
              field: 'amount',
              isVoiceInput: _enableVoiceInput,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Ngày',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Mô tả',
              field: 'description',
              isVoiceInput: _enableVoiceInput,
            ),
            const SizedBox(height: 16),
            isLoadingCategories
                ? const CircularProgressIndicator()  // Loading indicator when fetching categories
                : DropdownButtonFormField<String>(
                    value: _category,
                    hint: const Text('Chọn danh mục'),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value;
                      });
                      if (value != null) {
                        updateDescription(value);  // Update description based on selected category
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(),
                    ),
                  ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    bool isVoiceInput = false,
    required String field,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: const OutlineInputBorder(),
        suffixIcon: isVoiceInput
            ? IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () => _startListening(controller, field),
              )
            : null,
      ),
    );
  }
}
