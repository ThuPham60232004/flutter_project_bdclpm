import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
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
  List<dynamic> categories = [];
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.36:4000/api/categories'));
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
    if (category != null && category.containsKey('description')) {
      descriptionController.text = category['description'] ?? '';  
    }
  }

  @override
  void dispose() {
    storeNameController.dispose();
    totalAmountController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.dispose();
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
      (category) => category['name'] == selectedCategory,
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
      parsedDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ngày không hợp lệ, vui lòng nhập đúng định dạng (dd/MM/yyyy)!')),
      );
      return;
    }

    final formattedDate = parsedDate.toIso8601String();

    final expenseData = {
      'userId': userId,
      'storeName': storeNameController.text.trim(),
      'totalAmount': double.tryParse(totalAmountController.text) ?? 0,
      'date': formattedDate,
      'description': descriptionController.text.trim(),
      'categoryId': selectedCategoryId,
    };

    final response = await http.post(
      Uri.parse('http://192.168.1.36:4000/api/expenses'),
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

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final storeName = arguments['storeName'];
    final totalAmount = arguments['totalAmount'];
    final date = arguments['date'];
    selectedCategory = arguments['category'];
    imageUrl = arguments['imageUrl'];

    storeNameController.text = storeName;
    totalAmountController.text = totalAmount.toString();
    dateController.text = date;
    if (selectedCategory != null && categories.isNotEmpty) {
      updateDescription(selectedCategory!);
    }

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
                    onChanged: null,
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
                    onChanged: null, 
                  ),
                  RadioListTile(
                    title: Text('Nhận dạng giọng nói'),
                    value: 'voice',
                    groupValue: groupValue,
                    onChanged: null, 
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
                    dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
                  }
                },
              ),
              SizedBox(height: 16),
              isLoadingCategories
                  ? CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem(
                          value: category['name'], 
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                          updateDescription(value!); 
                        });
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
              ElevatedButton(
                onPressed: saveExpense, 
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
