import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_project_bdclpm/features/load/api/api.dart';

class UploadPage extends StatefulWidget {
  final String? title;
  const UploadPage({Key? key, this.title}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;
  Uint8List? _imageBytes;
  String? _imageName;
  String _extractedText = '';
  final picker = ImagePicker();
  CloudApi? api;
  bool isUploaded = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initializeApi();
  }

  Future<void> _initializeApi() async {
    try {
      final json = await rootBundle.loadString('assets/key/credentials.json');
      setState(() {
        api = CloudApi(json);
      });
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  Future<void> _getImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera, color: Colors.white),
              title: Text('Chụp ảnh từ camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.white),
              title: Text('Chọn ảnh từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      );

      if (source != null) {
        final pickedFile = await picker.pickImage(source: source);

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
            _imageBytes = _image?.readAsBytesSync();
            _imageName = _image?.path.split('/').last;
            isUploaded = false;
            _extractedText = '';
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveImage() async {
    if (_imageBytes == null || _imageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ảnh trước khi tải lên.')),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await api!.save(_imageName!, _imageBytes!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tải ảnh lên thành công!')),
      );
      setState(() {
        isUploaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải ảnh. Vui lòng thử lại.')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _extractText() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chưa chọn ảnh để trích xuất văn bản.')),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final resultJson = await api!.extractTextFromImage(_imageBytes!);
      final result = jsonDecode(resultJson);

      setState(() {
        _extractedText = result['status'] == 'success'
            ? result['text']
            : result['message'];
      });
    } catch (e) {
      print('Error extracting text: $e');
      setState(() {
        _extractedText = 'Lỗi trích xuất văn bản: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi trích xuất văn bản. Vui lòng thử lại.')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Upload to Google Cloud'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _imageBytes == null
                  ? Center(
                      child: Text(
                        'Chưa chọn ảnh.',
                        style: TextStyle(fontSize: 18, color: AppTheme.textColor),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryColor, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 16),
            if (!loading && !isUploaded)
              ElevatedButton.icon(
                onPressed: _saveImage,
                icon: Icon(Icons.cloud_upload, color: Colors.white),
                label: Text('Lưu lên Cloud',style:TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            if (loading)
              Center(child: CircularProgressIndicator()),
            if (isUploaded && !loading)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _extractText,
                    icon: Icon(Icons.text_snippet, color: Colors.white),
                    label: Text('Trích xuất văn bản', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                  ),
                  if (_extractedText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Văn bản đã trích xuất:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              constraints: BoxConstraints(maxHeight: 200),
                              child: SingleChildScrollView(
                                child: Text(
                                  _extractedText,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Chọn ảnh',
        child: Icon(Icons.add_a_photo, color: Colors.white),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }
}

class AppTheme {
  static final Color primaryColor = Color(0xFF4A90E2);
  static final Color secondaryColor = Color(0xFFF5F5F5);
  static final Color accentColor = Color(0xFFFF9500);
  static final Color textColor = Color(0xFF4A4A4A);
  static final Color successColor = Color.fromARGB(255, 132, 189, 239);
}
