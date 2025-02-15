import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/pdf_excel_controller.dart';
import 'package:flutter/services.dart';

class PdfExcelPage extends StatefulWidget {
  @override
  _PdfExcelPageState createState() => _PdfExcelPageState();
}

class _PdfExcelPageState extends State<PdfExcelPage> {
  final PdfExcelController _controller = PdfExcelController();
  String groupValue = 'pdf';

  @override
  void initState() {
    super.initState();
    _controller.fetchCategories();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
            const SizedBox(height: 15),
            _buildTextField(
              controller: _controller.storeNameController,
              label: 'Tên cửa hàng',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _controller.amountController,
              label: 'Số tiền',
              prefixText: 'VND ',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _controller.dateController,
              decoration: InputDecoration(
                labelText: 'Ngày',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _controller.dateController.text =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            _buildTextField(
                controller: _controller.descriptionController, label: 'Mô tả'),
            const SizedBox(height: 15),
            _controller.isLoadingCategories
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _controller.category,
                    hint: const Text("Chọn danh mục"),
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _controller.category = value;
                        _controller.updateDescription(value);
                      });
                    },
                    items: _controller.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _controller.pickPdfOrExcelFile();
                      _showSnackBar("Tệp đã được xử lý thành công.");
                    } catch (e) {
                      _showSnackBar("Lỗi: $e");
                    }
                  },
                  child: const Text('Chọn Tệp',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 35),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _controller.saveExpense();
                      _showSnackBar('Lưu chi tiêu thành công!');
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } catch (e) {
                      _showSnackBar('Đã xảy ra lỗi: $e');
                    }
                  },
                  child: const Text('Lưu chi tiêu',
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 35),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixText: prefixText,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}
