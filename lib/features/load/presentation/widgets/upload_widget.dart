import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadWidget extends StatefulWidget {
  final Function(String) onSuccess;

  UploadWidget({required this.onSuccess});

  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isUploading = false;

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  // Hàm tải ảnh lên Firebase Storage
  Future<void> _uploadReceipt() async {
    if (_image == null) {
      // Hiển thị thông báo nếu không có ảnh được chọn
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng chọn ảnh biên lai')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Lấy tên file ảnh
      String fileName = _image!.name;

      // Lấy reference đến bucket trong Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child('receipts/$fileName');

      // Tải ảnh lên Firebase Storage
      await storageRef.putFile(File(_image!.path));
      String downloadURL = await storageRef.getDownloadURL();

      // Gọi callback trả về URL của ảnh đã tải lên
      widget.onSuccess(downloadURL);

      setState(() {
        _isUploading = false;
      });

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ảnh biên lai đã được tải lên thành công!')));
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải ảnh lên: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Chọn ảnh biên lai'),
        ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(File(_image!.path)),
          ),
        if (_isUploading)
          CircularProgressIndicator(), // Hiển thị loading khi đang tải lên
        ElevatedButton(
          onPressed: _uploadReceipt,
          child: Text('Tải lên biên lai'),
        ),
      ],
    );
  }
}
