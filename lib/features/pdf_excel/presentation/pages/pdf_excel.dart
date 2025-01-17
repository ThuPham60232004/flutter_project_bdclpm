import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:excel/excel.dart';

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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _pickPdfOrExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xls', 'xlsx'],
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        if (filePath.endsWith('.pdf')) {
          _processPdfFile(filePath);
        } else if (filePath.endsWith('.xls') || filePath.endsWith('.xlsx')) {
          _processExcelFile(filePath);
        }
      } else {
        _showSnackBar("Không thể truy cập tệp.");
      }
    } else {
      _showSnackBar("Không có tệp nào được chọn.");
    }
  }

  void _processPdfFile(String filePath) async {
    try {
      final File file = File(filePath);
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      String? storeName = _extractStoreName(extractedText);
      String? totalAmount = _extractTotalAmount(extractedText);
      String? date = _extractDate(extractedText);

      setState(() {
        _storeNameController.text = storeName ?? "Không tìm thấy tên cửa hàng";
        _amountController.text = totalAmount ?? "0";
        _dateController.text = date ?? DateTime.now().toString();
        _descriptionController.text = "Trích xuất từ PDF";
      });

      _showSnackBar("Tệp PDF đã được xử lý thành công.");
    } catch (e) {
      _showSnackBar("Lỗi khi xử lý PDF: $e");
    }
  }

  String? _extractStoreName(String text) {
    final List<RegExp> storeNamePatterns = [
      RegExp(r'^Công ty.*$', multiLine: true),
      RegExp(r'^TRƯỜNG.*$', multiLine: true),
      RegExp(r'^Nhà hàng.*$', multiLine: true),
    ];

    for (var pattern in storeNamePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0)?.trim();
      }
    }
    return null;
  }

  String? _extractTotalAmount(String text) {
    String normalizedText = _removeAccents(text.toLowerCase());
    final RegExp pattern = RegExp(r'(tổng cộng|total|tổng)\s*[:\-]?\s*([\d.,]+)');
    final match = pattern.firstMatch(normalizedText);
    if (match != null) {
      return match.group(2)?.replaceAll(RegExp(r'[^\d]'), '');
    }
    return null;
  }

  String _removeAccents(String text) {
    const Map<String, String> accents = {
      'á': 'a', 'à': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
      'é': 'e', 'è': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
      'ó': 'o', 'ò': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
      'ú': 'u', 'ù': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
      'ý': 'y', 'ỳ': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
      'đ': 'd'
    };

    return text.split('').map((char) => accents[char] ?? char).join('');
  }

  String? _extractDate(String text) {
    final RegExp datePattern = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      return '${match.group(1)}/${match.group(2)}/${match.group(3)}';
    }
    return null;
  }

  void _processExcelFile(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]?.rows;
        if (rows != null && rows.isNotEmpty) {
          setState(() {
            _storeNameController.text = rows[0][0]?.value?.toString() ?? "";
            _amountController.text = rows[0][1]?.value?.toString() ?? "0";
            _dateController.text = rows[0][2]?.value?.toString() ?? "";
            _category = rows[0][3]?.value?.toString() ?? "Khác";
            _descriptionController.text = rows[0][4]?.value?.toString() ?? "";
          });
          _showSnackBar("Tệp Excel đã được xử lý thành công.");
          break;
        }
      }
    } catch (e) {
      _showSnackBar("Lỗi khi xử lý Excel: $e");
    }
  }

  void _saveExpense() {
    final expenseData = {
      'storeName': _storeNameController.text,
      'amount': double.tryParse(_amountController.text) ?? 0,
      'date': _dateController.text,
      'description': _descriptionController.text,
      'category': _category,
    };

    print("Lưu chi tiêu: $expenseData");
    _showSnackBar("Chi tiêu đã được lưu thành công.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xử lý PDF/Excel'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _storeNameController,
              label: 'Tên cửa hàng',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _amountController,
              label: 'Số tiền',
              prefixText: 'VND ',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Ngày',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Mô tả',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              hint: const Text('Chọn danh mục'),
              items: [
                "Thực phẩm",
                "Điện tử",
                "Dịch vụ",
                "Thời trang",
                "Vận chuyển",
                "Khác",
              ].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
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
                onPressed: _pickPdfOrExcelFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Chọn tệp PDF/Excel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Lưu chi tiêu'),
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
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixText: prefixText,
      ),
      keyboardType: keyboardType,
    );
  }
}
