import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/manual_voice_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualVoicePage extends StatefulWidget {
  const ManualVoicePage({Key? key}) : super(key: key);
  @override
  _ManualVoicePageState createState() => _ManualVoicePageState();
}

class _ManualVoicePageState extends State<ManualVoicePage> {
  late ExpenseManager _expenseManager;

  @override
  void initState() {
    super.initState();
    _expenseManager = ExpenseManager(
      (message) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message))),
      SharedPreferences.getInstance(),
    );
    _expenseManager.fetchCategories();
  }

  @override
  void dispose() {
    _expenseManager.storeNameController.dispose();
    _expenseManager.amountController.dispose();
    _expenseManager.dateController.dispose();
    _expenseManager.descriptionController.dispose();
    super.dispose();
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
              value: !_expenseManager.enableVoiceInput,
              onChanged: (value) {
                setState(() {
                  _expenseManager.setEnableVoiceInput(!value!);
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
              value: _expenseManager.enableVoiceInput,
              onChanged: (value) {
                setState(() {
                  _expenseManager.setEnableVoiceInput(value!);
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              controller: _expenseManager.storeNameController,
              label: 'Tên cửa hàng',
              field: 'storeName',
              isVoiceInput: _expenseManager.enableVoiceInput,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              controller: _expenseManager.amountController,
              label: 'Số tiền',
              prefixText: 'VND ',
              keyboardType: TextInputType.number,
              field: 'amount',
              isVoiceInput: _expenseManager.enableVoiceInput,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expenseManager.dateController,
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
                    _expenseManager.dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              controller: _expenseManager.descriptionController,
              label: 'Mô tả',
              field: 'description',
              isVoiceInput: _expenseManager.enableVoiceInput,
            ),
            const SizedBox(height: 16),
            _expenseManager.isLoadingCategories
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _expenseManager.category,
                    hint: const Text('Chọn danh mục'),
                    items: _expenseManager.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _expenseManager.setCategory(value);
                      });
                      if (value != null) {
                        _expenseManager.updateDescription(value);
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
                onPressed: () => _expenseManager.saveExpense(),
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

  Widget _buildTextField(
    BuildContext context, {
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
      inputFormatters:
          field == 'amount' ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: const OutlineInputBorder(),
        suffixIcon: isVoiceInput
            ? IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () =>
                    _expenseManager.startListening(controller, field),
              )
            : null,
      ),
    );
  }
}
