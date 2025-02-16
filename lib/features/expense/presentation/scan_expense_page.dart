import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/scan_expense_controller.dart';
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
  final ScanExpenseController _controller = ScanExpenseController();
  int selectedMethod = 1;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<Map<String, dynamic>> _methods = [
    {'value': 0, 'label': "Nhập thủ công", 'enabled': false},
    {'value': 1, 'label': "Quét hóa đơn", 'enabled': true},
    {'value': 2, 'label': "Quét pdf/excel", 'enabled': false},
    {'value': 3, 'label': "Nhận dạng giọng nói", 'enabled': false},
  ];

  @override
  void initState() {
    super.initState();
    _controller.loadUserId();
    dateController.text = widget.date;
    amountController.text = _controller.formatCurrency(widget.totalAmount);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

Widget _buildTextField(String label, String value, {bool isDropdown = false, TextEditingController? controller, List<TextInputFormatter>? inputFormatters}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: isDropdown ? null : controller ?? TextEditingController(text: value),
      readOnly: isDropdown,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isDropdown ? const Icon(Icons.arrow_drop_down) : null,
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm chi tiêu", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bạn muốn nhập chi tiêu như thế nào?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ..._methods.map((method) => RadioListTile<int>(
                  value: method['value'] as int,
                  groupValue: selectedMethod,
                  onChanged: method['enabled'] ? (int? value) => setState(() => selectedMethod = value!) : null,
                  title: Text(method['label'] as String),
                )),
            const SizedBox(height: 12),
            _buildTextField("Tên cửa hàng", widget.storeName),
            _buildTextField("Số tiền", _controller.formatCurrency(widget.totalAmount)),
            _buildTextField(
              "Ngày",
              widget.date,
              controller: dateController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                DateInputFormatter(),
              ],
            ),
            _buildTextField("Mô tả", widget.description),
            _buildTextField("Danh mục", widget.categoryname),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _controller.createExpense(
                    storeName: widget.storeName,
                    totalAmount: widget.totalAmount,
                    description: widget.description,
                    date: widget.date,
                    categoryId: widget.categoryId,
                  );
                  _showSnackBar("Chi tiêu đã được tạo thành công");
                  Navigator.pop(context);
                } catch (e) {
                  _showSnackBar("Lỗi: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Lưu chi tiêu", style: TextStyle(color: Colors.white, fontSize: 16)),
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
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), ''); // Chỉ giữ lại số

    if (digitsOnly.isEmpty) return newValue;

    List<String> parts = [];

    if (digitsOnly.length >= 2) {
      parts.add(digitsOnly.substring(0, 2).padLeft(2, '0')); // Ngày
    }
    if (digitsOnly.length >= 4) {
      parts.add(digitsOnly.substring(2, 4).padLeft(2, '0')); // Tháng
    }
    if (digitsOnly.length > 4) {
      parts.add(digitsOnly.substring(4, digitsOnly.length.clamp(4, 8))); // Năm
    }

    String formattedText = parts.join('/');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}