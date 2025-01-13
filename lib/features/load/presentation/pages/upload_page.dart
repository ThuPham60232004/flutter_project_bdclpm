import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_project_bdclpm/features/load/api/api.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/pages/expense_page.dart';

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
  String? imageUrl; 
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
              leading: Icon(Icons.camera, color: Colors.blue),
              title: Text('Chụp ảnh từ camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.blue),
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
    // Gửi ảnh lên Cloud và lấy URL trả về
    imageUrl = await api!.saveAndGetUrl(_imageName!, _imageBytes!);

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

      if (result['status'] == 'success') {
        final text = result['text'];
        setState(() {
          _extractedText = text;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Lỗi trích xuất văn bản.')),
        );
      }
    } catch (e) {
      print('Error extracting text: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi trích xuất văn bản. Vui lòng thử lại.')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

void _navigateToReviewPage() {
  if (_extractedText.isEmpty || imageUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vui lòng tải ảnh và trích xuất văn bản trước.')),
    );
    return;
  }

  final extractedData = _processExtractedText(_extractedText);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ExpenseReviewPage(
        extractedData: extractedData,
        imageUrl: imageUrl!, 
      ),
    ),
  );
}


  Map<String, dynamic> _processExtractedText(String text) {
    final lines = text.split('\n');
    final List<Map<String, dynamic>> items = [];
    double? total;

    for (var line in lines) {
      if (line.toLowerCase().contains('tien mat')) {
        total = double.tryParse(
            line.replaceAll(RegExp(r'[^\d.]'), '').trim());
      } else {
        final match = RegExp(r'^(?<quantity>\d+)?\s*(?<name>.+)\s+(?<price>\d{1,3}(?:,\d{3})*)$')
            .firstMatch(line);
        if (match != null) {
          final name = match.namedGroup('name')?.trim() ?? '';
          final price = double.tryParse(
                  match.namedGroup('price')!.replaceAll(',', '').trim()) ??
              0.0;
          items.add({"name": name, "price": price});
        }
      }
    }

    return {
      "total": total ?? 0.0,
      "items": items,
    };
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
                label: Text('Lưu lên Cloud'),
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
                    label: Text('Trích xuất văn bản'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                  ),
                  if (_extractedText.isNotEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text('Văn bản đã trích xuất: $_extractedText'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _navigateToReviewPage,
                          icon: Icon(Icons.check, color: Colors.white),
                          label: Text('Lưu và tiếp tục'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        ),
                      ],
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
  static final Color accentColor = Color(0xFFFF9500);
  static final Color successColor = Color(0xFF4CAF50);
  static final Color textColor = Color(0xFF4A4A4A);
}
