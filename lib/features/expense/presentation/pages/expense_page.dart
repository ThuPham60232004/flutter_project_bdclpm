import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseReviewPage extends StatefulWidget {
  final Map<String, dynamic> extractedData;
  final String imageUrl; // URL of uploaded image.

  ExpenseReviewPage({required this.extractedData, required this.imageUrl});

  @override
  _ExpenseReviewPageState createState() => _ExpenseReviewPageState();
}

class _ExpenseReviewPageState extends State<ExpenseReviewPage> {
  late List<Map<String, dynamic>> items;
  late double total;
  String? selectedCategory;
  String? note;

  @override
  void initState() {
    super.initState();
    // Kiểm tra xem 'receipt' có null không trước khi parse
    String receipt = widget.extractedData['receipt'] ?? ''; // Nếu 'receipt' là null, gán chuỗi rỗng
    items = parseReceipt(receipt);
    total = widget.extractedData['total'];
  }

  // Phương thức để phân tích hóa đơn
  List<Map<String, dynamic>> parseReceipt(String receipt) {
    final items = <Map<String, dynamic>>[];
    final lines = receipt.split('\n');

    for (var line in lines) {
      // Loại bỏ các dòng không liên quan
      if (line.contains('CA') || line.contains('TIEN MAT') || line.contains('HEN GAP LAI') || line.isEmpty) {
        continue;
      }

      final parts = line.trim().split(RegExp(r'\s{2,}')); // Tách theo khoảng trắng dài (giữa tên món và giá)
      
      // Kiểm tra nếu dòng có 2 phần: tên món và giá
      if (parts.length == 2) {
        final name = parts[0].trim();
        final priceString = parts[1].replaceAll(',', '').trim();
        final price = double.tryParse(priceString) ?? 0.0;

        // Kiểm tra xem có phải là món ăn với giá hợp lệ
        if (name.isNotEmpty && price > 0) {
          items.add({'name': name, 'price': price});
        }
      }
    }

    return items;
  }

  // Fetch categories from Firestore
  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) {
      return {'id': doc.id, 'name': doc['name']};
    }).toList();
  }

  // Save expense to Firestore
  Future<void> _saveExpense() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn danh mục!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'total': total,
        'category': FirebaseFirestore.instance.collection('categories').doc(selectedCategory),
        'items': items,
        'imageUrl': widget.imageUrl,
        'note': note ?? '',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chi tiêu đã được lưu thành công!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lưu chi tiêu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xem và chỉnh sửa chi tiêu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ảnh hóa đơn:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              widget.imageUrl.isNotEmpty
                  ? Image.network(widget.imageUrl)
                  : Text('Không có ảnh', style: TextStyle(color: Colors.red)),
              Divider(),
              Text('Danh sách sản phẩm:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['name']),
                    trailing: Text('${item['price']} VND'),
                  );
                },
              ),
              Divider(),
              Text('Tổng cộng: ${total.toStringAsFixed(0)} VND',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Chọn danh mục:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Không thể tải danh mục');
                  }

                  final categories = snapshot.data!;
                  return DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    hint: Text('Chọn danh mục'),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 20),
              Text('Ghi chú:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập ghi chú (nếu có)',
                ),
                onChanged: (value) {
                  setState(() {
                    note = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text('Lưu chi tiêu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
