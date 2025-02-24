import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan_expense_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScanPage extends StatefulWidget {
  final String? title;
  const ScanPage({Key? key, this.title}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
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
      final credentialsJson =
          await rootBundle.loadString('assets/key/credentials.json');
      api = CloudApi(credentialsJson);
      debugPrint('✅ API initialized: $api');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing API: $e\n$stackTrace');
    }
  }

  Future<void> _getImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSourceOption(
                Icons.camera, 'Take a photo', ImageSource.camera),
            _buildSourceOption(Icons.photo_library, 'Choose from gallery',
                ImageSource.gallery),
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
      debugPrint('Error selecting image: $e');
    }
  }

  ListTile _buildSourceOption(IconData icon, String text, ImageSource source) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text),
      onTap: () => Navigator.pop(context, source),
    );
  }

  Future<void> _saveImage() async {
    if (_imageBytes == null || _imageName == null) {
      _showSnackBar('Please select an image before uploading.');
      return;
    }

    setState(() => loading = true);

    try {
      imageUrl = await api!.saveAndGetUrl(_imageName!, _imageBytes!);
      _showSnackBar('Image uploaded successfully!');
      setState(() => isUploaded = true);
    } catch (e) {
      _showSnackBar('Error uploading image. Please try again.');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _extractText() async {
    if (_imageBytes == null) {
      _showSnackBar('No image selected for text extraction.');
      return;
    }

    setState(() => loading = true);

    try {
      final resultJson = await api!.extractTextFromImage(_imageBytes!);
      setState(() {
        _extractedText =
            const JsonEncoder.withIndent("  ").convert(json.decode(resultJson));
      });
    } catch (e) {
      debugPrint('Error extracting text: $e');
      _showSnackBar('Error extracting text. Please try again.');
    } finally {
      setState(() => loading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Upload to Google Cloud'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _imageBytes == null
                  ? Center(
                      child: Text(
                        'No image selected.',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    )
                  : _buildImagePreview(),
              const SizedBox(height: 16),
              if (!loading && !isUploaded) _buildUploadButton(),
              if (loading) const Center(child: CircularProgressIndicator()),
              if (isUploaded && !loading) _buildPostUploadOptions(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Select image',
        child: const Icon(Icons.add_a_photo, color: Colors.white),
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: _saveImage,
      icon: const Icon(Icons.cloud_upload, color: Colors.white),
      label:
          const Text('Upload to Cloud', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    );
  }

  Widget _buildPostUploadOptions() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _extractText,
          icon: const Icon(Icons.text_snippet, color: Colors.black),
          label:
              const Text('Extract Text', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        ),
        const SizedBox(height: 16),
        if (_extractedText.isNotEmpty)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SelectableText(
                    _extractedText,
                    style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final extractedData = json.decode(_extractedText);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanExpensePage(
                        storeName: extractedData['data']['storeName'] ?? '',
                        totalAmount: _parseTotalAmount(
                            extractedData['data']['totalAmount']),
                        description: extractedData['data']['category']
                                ['description'] ??
                            '',
                        date: extractedData['data']['date'] ?? '',
                        categoryId:
                            extractedData['data']['category']['_id'] ?? '',
                        categoryname:
                            extractedData['data']['category']['name'] ?? '',
                        currency: extractedData['data']['currency'] ?? 'VND',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('Continue',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
            ],
          ),
      ],
    );
  }

  double _parseTotalAmount(dynamic totalAmount) {
    if (totalAmount == null) return 0.0;
    String amountStr = totalAmount.toString().replaceAll(
          ',',
          '',
        );
    return double.tryParse(amountStr) ?? 0.0;
  }
}
