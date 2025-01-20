import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PdfExcelPage extends StatefulWidget {
  @override
  _PdfExcelPageState createState() => _PdfExcelPageState();
}

class _PdfExcelPageState extends State<PdfExcelPage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _category;
  List<dynamic> categories = [];
  bool isLoadingCategories = true;
  String groupValue = 'pdf';
  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.213:4000/api/categories'));
      if (response.statusCode == 200) {
        categories = json.decode(response.body);
      } else {
        _showSnackBar('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      setState(() => isLoadingCategories = false);
    }
  }

  void updateDescription(String? categoryName) {
    final category = categories.firstWhere(
      (cat) => cat['name'] == categoryName,
      orElse: () => null,
    );
    if (category != null) {
      _descriptionController.text = category['description'] ?? '';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickPdfOrExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xls', 'xlsx'],
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        filePath.endsWith('.pdf') ? _processPdfFile(filePath) : _processExcelFile(filePath);
      } else {
        _showSnackBar("Không thể truy cập tệp.");
      }
    } else {
      _showSnackBar("Không có tệp nào được chọn.");
    }
  }

  String removeDiacritics(String text) {
    const accents = {
      'á': 'a', 'à': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
      'é': 'e', 'è': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
      'ó': 'o', 'ò': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
      'ú': 'u', 'ù': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
      'ý': 'y', 'ỳ': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
      'đ': 'd',
    };
    return text.split('').map((char) => accents[char] ?? char).join('');
  }

  String categorizeInvoice(String storeName) {
  List<String> foodKeywords = ['cơm', 'mì', 'phở', 'bánh mì', 'chè', 'sữa chua'];
  List<String> electronicsKeywords = ['laptop', 'phone', 'tv', 'máy tính'];
  List<String> serviceKeywords = ['dịch vụ', 'spa', 'thẩm mỹ', 'trường', 'đại học'];
  List<String> clothingKeywords = ['áo', 'quần', 'váy', 'giày', 'túi'];
  List<String> transportationKeywords = ['vé', 'xe', 'tàu', 'máy bay', 'chuyến bay'];

  List<String> foodStoreKeywords = ['siêu thị', 'cửa hàng thực phẩm', 'gian hàng thực phẩm'];
  List<String> electronicsStoreKeywords = ['cửa hàng điện tử', 'trung tâm điện tử', 'máy tính'];
  List<String> serviceStoreKeywords = ['dịch vụ', 'spa', 'thẩm mỹ viện', 'trường', 'đại học', 'học phí'];
  List<String> clothingStoreKeywords = ['shop quần áo', 'thời trang', 'shop giày dép'];
  List<String> transportationStoreKeywords = ['vé tàu', 'vé máy bay', 'dịch vụ vận tải'];

  final normalizedStoreName = removeDiacritics(storeName.toLowerCase());

  bool containsKeywords(List<String> keywords) {
    return keywords.any((kw) => normalizedStoreName.contains(kw));
  }

  if (containsKeywords(foodKeywords) || containsKeywords(foodStoreKeywords)) {
    return 'Thực phẩm';
  }
  if (containsKeywords(electronicsKeywords) || containsKeywords(electronicsStoreKeywords)) {
    return 'Điện tử';
  }
  if (containsKeywords(serviceKeywords) || containsKeywords(serviceStoreKeywords)) {
    return 'Dịch vụ';
  }
  if (containsKeywords(clothingKeywords) || containsKeywords(clothingStoreKeywords)) {
    return 'Thời trang';
  }
  if (containsKeywords(transportationKeywords) || containsKeywords(transportationStoreKeywords)) {
    return 'Vận chuyển';
  }

  return 'Khác';
}


  void _processPdfFile(String filePath) async {
    try {
      final document = PdfDocument(inputBytes: await File(filePath).readAsBytes());
      final extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      final storeName = _extractStoreName(extractedText);
      final totalAmount = _extractTotalAmount(extractedText);
      final date = _extractDate(extractedText);

      setState(() {
        _storeNameController.text = storeName ?? "Không tìm thấy tên cửa hàng";
        _amountController.text = totalAmount ?? "0";
        _dateController.text = date ?? DateTime.now().toString();
        _category = categorizeInvoice(storeName ?? "");
        _descriptionController.text = "Trích xuất từ PDF";
      });

      _showSnackBar("Tệp PDF đã được xử lý thành công.");
    } catch (e) {
      _showSnackBar("Lỗi khi xử lý PDF: $e");
    }
  }

  String? _extractStoreName(String text) {
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

  String? _extractTotalAmount(String text) {
    final pattern = RegExp(r'(tổng cộng|total|tổng)\s*[:\-]?\s*([\d.,]+)', caseSensitive: false);
    final match = pattern.firstMatch(removeDiacritics(text));
    return match?.group(2)?.replaceAll(RegExp(r'[^\d]'), '');
  }

  String? _extractDate(String text) {
    final match = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})').firstMatch(text);
    return match != null ? '${match.group(1)}/${match.group(2)}/${match.group(3)}' : null;
  }

  void _processExcelFile(String filePath) async {
    try {
      final excel = Excel.decodeBytes(await File(filePath).readAsBytesSync());
      final rows = excel.tables.values.first.rows;

      if (rows.isNotEmpty) {
        setState(() {
          _storeNameController.text = rows[0][0]?.value?.toString() ?? "";
          _amountController.text = rows[0][1]?.value?.toString() ?? "0";
          _dateController.text = rows[0][2]?.value?.toString() ?? "";
          _category = rows[0][3]?.value?.toString() ?? "Khác";
          _descriptionController.text = rows[0][4]?.value?.toString() ?? "";
        });
        _showSnackBar("Tệp Excel đã được xử lý thành công.");
      }
    } catch (e) {
      _showSnackBar("Lỗi khi xử lý Excel: $e");
    }
  }

  Future<void> saveExpense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) throw Exception('Không tìm thấy thông tin người dùng');

      final selectedCategoryId = categories.firstWhere((cat) => cat['name'] == _category)?['_id'];
      if (selectedCategoryId == null) throw Exception('Danh mục không hợp lệ');

      final parsedDate = DateTime.parse(_dateController.text); // Chuyển đổi từ chuỗi ISO 8601
      final formattedDate = parsedDate.toIso8601String(); // Hoặc định dạng tùy ý


      final expenseData = {
        'userId': userId,
        'storeName': _storeNameController.text.trim(),
        'totalAmount': double.tryParse(_amountController.text) ?? 0,
        'date': formattedDate,
        'description': _descriptionController.text.trim(),
        'categoryId': selectedCategoryId,
      };

      final response = await http.post(
        Uri.parse('http://192.168.1.213:4000/api/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expenseData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Lưu chi tiêu thành công!');
      } else {
        throw Exception('Lỗi khi lưu chi tiêu: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xử lý PDF/Excel'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
                  RadioListTile(
                    title: Text('Nhập thủ công'),
                    value: 'manual',
                    groupValue: groupValue,
                    onChanged: null,
                  ),
                  RadioListTile(
                    title: Text('Quét hóa đơn'),
                    value: 'invoice',
                    groupValue: groupValue,
                    onChanged: null,
                  ),
                  RadioListTile(
                    title: Text('Quét PDF/Excel'),
                    value: 'pdf',
                    groupValue: groupValue,
                    onChanged: (value) {
                      setState(() {
                        groupValue = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Nhận dạng giọng nói'),
                    value: 'voice',
                    groupValue: groupValue,
                    onChanged: null, 
                  ),
            _buildTextField(controller: _storeNameController, label: 'Tên cửa hàng'),
            _buildTextField(controller: _amountController, label: 'Số tiền', prefixText: 'VND ', keyboardType: TextInputType.number),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Ngày', border: OutlineInputBorder()),
              readOnly: true,
            ),
            _buildTextField(controller: _descriptionController, label: 'Mô tả'),
            isLoadingCategories
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  value: _category,
                  hint: const Text("Chọn danh mục"),
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                      updateDescription(value);
                    });
                  },
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'],
                      child: Text(category['name']),
                    );
                  }).toList(),
                ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _pickPdfOrExcelFile,
                  child: const Text('Chọn Tệp', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 13,horizontal: 35),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    ),
                  )
                ),
                ElevatedButton(
                  onPressed: saveExpense,
                  child: const Text('Lưu chi tiêu', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13,horizontal: 35),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    ),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String prefixText = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixText: prefixText,
        ),
      ),
    );
  }
}
