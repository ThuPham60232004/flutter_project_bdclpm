import 'package:flutter/material.dart';

class TypePage extends StatefulWidget {
  const TypePage({super.key});

  @override
  State<TypePage> createState() => _TypePage();
}

class _TypePage extends State<TypePage> {
  String? selectedOption;
  static const String manualvoice = '/manualvoice';
  static const String scan = '/scan';
  static const String pdfexcel = '/pdfexcel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            const Text('Chọn kiểu nhập', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 46.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thêm chi tiêu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bạn muốn nhập chi tiêu như thế nào',
                style: TextStyle(),
              ),
              const SizedBox(height: 8),
              buildOptionRow('Nhập thủ công, giọng nói', manualvoice),
              buildOptionRow('Quét hóa đơn', scan),
              buildOptionRow('Quét pdf/excel', pdfexcel),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionRow(String text, String route) {
    return Row(
      children: <Widget>[
        Radio<String>(
          value: route,
          groupValue: selectedOption,
          onChanged: (String? newValue) {
            setState(() {
              selectedOption = newValue;
            });
            if (newValue != null) {
              Navigator.pushNamed(context, newValue);
            }
          },
          activeColor: Colors.grey,
          fillColor: MaterialStateProperty.all(Colors.grey),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 13.0),
        ),
      ],
    );
  }
}
