import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/load/presentation/widgets/upload_widget.dart';  // Import đúng widget

class UploadPage extends StatelessWidget {
  // Callback để nhận URL của biên lai sau khi tải lên thành công
  void _onReceiptUploaded(String url) {
    print('URL của biên lai: $url');
    // Bạn có thể thực hiện các hành động khác như lưu URL vào cơ sở dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Biên Lai')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: UploadWidget(
            onSuccess: _onReceiptUploaded, // Truyền callback vào widget UploadWidget
          ),
        ),
      ),
    );
  }
}
