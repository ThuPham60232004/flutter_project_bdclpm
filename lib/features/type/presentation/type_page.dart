import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project_bdclpm/features/type/controllers.dart/type_page_controller.dart';

class TypePage extends StatelessWidget {
  const TypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TypePageController(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Chọn kiểu nhập',
              style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 46.0),
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
                Consumer<TypePageController>(
                  builder: (context, controller, child) {
                    return Column(
                      children: [
                        buildOptionRow(context, 'Nhập thủ công, giọng nói',
                            TypePageController.manualvoice, controller),
                        buildOptionRow(context, 'Quét hóa đơn',
                            TypePageController.scan, controller),
                        buildOptionRow(context, 'Quét pdf/excel',
                            TypePageController.pdfexcel, controller),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOptionRow(BuildContext context, String text, String route,
      TypePageController controller) {
    return Row(
      children: <Widget>[
        Radio<String>(
          value: route,
          groupValue: controller.selectedOption,
          onChanged: (String? newValue) =>
              controller.selectOption(context, newValue),
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
