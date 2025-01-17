import 'package:flutter/material.dart';

class ScanExpensePage extends StatefulWidget {
  @override
  _ScanExpensePageState createState() => _ScanExpensePageState();
}

class _ScanExpensePageState extends State<ScanExpensePage> {
  String? selectedCategory;
  String? imageUrl;
  bool includeVat = false; 
  final storeNameController = TextEditingController();
  final totalAmountController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();
  String groupValue = 'invoice'; 

  @override
  void dispose() {
    storeNameController.dispose();
    totalAmountController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final storeName = arguments['storeName'];
    final totalAmount = arguments['totalAmount'];
    final date = arguments['date'];
    selectedCategory = arguments['category'];
    imageUrl = arguments['imageUrl']; 
    debugPrint("Image URL: $imageUrl");

    storeNameController.text = storeName;
    totalAmountController.text = totalAmount.toString();
    dateController.text = date;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm chi tiêu'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn muốn nhập chi tiêu như thế nào?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile(
                    title: Text('Nhập thủ công'),
                    value: 'manual',
                    groupValue: groupValue,
                    onChanged: null, // Disabled
                  ),
                  RadioListTile(
                    title: Text('Quét hóa đơn'),
                    value: 'invoice',
                    groupValue: groupValue,
                    onChanged: (value) {
                      setState(() {
                        groupValue = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Quét PDF/Excel'),
                    value: 'pdf',
                    groupValue: groupValue,
                    onChanged: null, // Disabled
                  ),
                  RadioListTile(
                    title: Text('Nhận dạng giọng nói'),
                    value: 'voice',
                    groupValue: groupValue,
                    onChanged: null, // Disabled
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: storeNameController,
                decoration: InputDecoration(
                  labelText: 'Tên cửa hàng',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: totalAmountController,
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  prefixText: 'VND ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Ngày',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    dateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format the date
                  }
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                value: selectedCategory,
                items: [
                  DropdownMenuItem(value: 'Thực phẩm', child: Text('Thực phẩm')),
                  DropdownMenuItem(value: 'Điện tử', child: Text('Điện tử')),
                  DropdownMenuItem(value: 'Dịch vụ', child: Text('Dịch vụ')),
                  DropdownMenuItem(value: 'Thời trang', child: Text('Thời trang')),
                  DropdownMenuItem(value: 'Vận chuyển', child: Text('Vận chuyển')),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final expenseData = {
                    'storeName': storeNameController.text,
                    'totalAmount': double.tryParse(totalAmountController.text) ?? 0,
                    'date': dateController.text,
                    'description': descriptionController.text,
                    'category': selectedCategory,
                    'includeVat': includeVat,
                  };
                  debugPrint('Expense data: $expenseData');
                },
                child: Text('Lưu chi tiêu'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
