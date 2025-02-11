import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ScanExpensePage extends StatefulWidget {
  final String storeName;
  final double totalAmount;
  final String description;
  final String date;
  final String categoryId;
  final String categoryname;
  const ScanExpensePage({
    Key? key,
    required this.storeName,
    required this.totalAmount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.categoryname,
  }) : super(key: key);

  @override
  _ScanExpensePageState createState() => _ScanExpensePageState();
}

class _ScanExpensePageState extends State<ScanExpensePage> {
  String? userId;
  int selectedMethod = 1;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    dateController.text = widget.date;
    amountController.text = _formatCurrency(widget.totalAmount);
  }

  String _convertToIsoDate(String date) {
    try {
      DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(date);
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return date;
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  void _createExpense() async {
    if (userId == null) return;

    final expenseData = {
      "userId": userId,
      "storeName": widget.storeName,
      "totalAmount": widget.totalAmount,
      "description": widget.description,
      "date": _convertToIsoDate(dateController.text),
      "categoryId": widget.categoryId,
    };

    final response = await http.post(
      Uri.parse("https://backend-bdclpm.onrender.com/api/expenses"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(expenseData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Chi tiêu đã được tạo thành công")),
      );
      Navigator.pop(context);
    } else {
      print("Error: ${response.statusCode}");
      print("Response body: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tạo chi tiêu. Vui lòng thử lại!")),
      );
    }
  }

  String _formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'vi_VN');
    return formatter.format(amount);
  }

  Widget _buildTextField(String label, String value,
      {bool isDropdown = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: isDropdown ? null : TextEditingController(text: value),
        readOnly: isDropdown ? true : false,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: isDropdown ? Icon(Icons.arrow_drop_down) : null,
        ),
        inputFormatters: label == "Ngày"
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                DateInputFormatter(),
              ]
            : label == "Số tiền"
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ]
                : [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm chi tiêu",
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: BackButton(),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bạn muốn nhập chi tiêu như thế nào?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            RadioListTile(
              value: 0,
              groupValue: selectedMethod,
              onChanged: null,
              title: Text("Nhập thủ công"),
            ),
            RadioListTile(
              value: 1,
              groupValue: selectedMethod,
              onChanged: (value) =>
                  setState(() => selectedMethod = value as int),
              title: Text("Quét hóa đơn"),
            ),
            RadioListTile(
              value: 2,
              groupValue: selectedMethod,
              onChanged: null,
              title: Text("Quét pdf/excel"),
            ),
            RadioListTile(
              value: 3,
              groupValue: selectedMethod,
              onChanged: null,
              title: Text("Nhận dạng giọng nói"),
            ),
            const SizedBox(height: 12),
            _buildTextField("Tên cửa hàng", widget.storeName),
            _buildTextField("Số tiền", _formatCurrency(widget.totalAmount),
                isDropdown: false),
            _buildTextField("Ngày", widget.date),
            _buildTextField("Mô tả", widget.description),
            _buildTextField("Danh mục", widget.categoryname),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Lưu chi tiêu",
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255), fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    if (newText.length > 2 && newText[2] != '/') {
      newText = newText.substring(0, 2) + '/' + newText.substring(2);
    }

    if (newText.length > 5 && newText[5] != '/') {
      newText = newText.substring(0, 5) + '/' + newText.substring(5);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
