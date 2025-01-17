import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ManualVoicePage extends StatefulWidget {
  @override
  _ManualVoicePageState createState() => _ManualVoicePageState();
}

class _ManualVoicePageState extends State<ManualVoicePage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _category;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _enableVoiceInput = false;
  String _speechResult = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showSnackBar('Quyền micro chưa được cấp! Vui lòng cấp quyền trong cài đặt.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _startListening(TextEditingController controller) async {
    await _checkMicrophonePermission();
    bool available = await _speech.initialize(
      onStatus: (status) => print('Trạng thái: $status'),
      onError: (error) => print('Lỗi: ${error.errorMsg}'),
    );
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        setState(() {
          controller.text = result.recognizedWords;
        });
      });
    } else {
      _showSnackBar('Không thể sử dụng ghi âm');
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  void _saveExpense() {
    if (_storeNameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _category == null) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanExpensePage(),
        settings: RouteSettings(
          arguments: {
            'storeName': _storeNameController.text,
            'date': _dateController.text,
            'totalAmount': _amountController.text,
            'category': _category,
            'description': _descriptionController.text,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm chi tiêu'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn muốn nhập chi tiêu như thế nào?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text("Nhập thủ công"),
              value: !_enableVoiceInput,
              onChanged: (value) {
                setState(() {
                  _enableVoiceInput = !value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text("Quét hóa đơn"),
              value: false,
              onChanged: null,
            ),
            CheckboxListTile(
              title: const Text("Quét PDF/Excel"),
              value: false,
              onChanged: null, 
            ),
            CheckboxListTile(
              title: const Text("Nhận dạng giọng nói"),
              value: _enableVoiceInput,
              onChanged: (value) {
                setState(() {
                  _enableVoiceInput = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _storeNameController,
              label: 'Tên cửa hàng',
              isVoiceInput: _enableVoiceInput,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _amountController,
              label: 'Số tiền',
              prefixText: 'VND ',
              keyboardType: TextInputType.number,
              isVoiceInput: _enableVoiceInput,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Ngày',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Mô tả',
              isVoiceInput: _enableVoiceInput,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              hint: const Text('Chọn danh mục'),
              items: [
                "Thực phẩm",
                "Điện tử",
                "Dịch vụ",
                "Thời trang",
                "Vận chuyển",
                "Khác",
              ].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    bool isVoiceInput = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: const OutlineInputBorder(),
        suffixIcon: isVoiceInput
            ? IconButton(
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                onPressed: _isListening
                    ? _stopListening
                    : () => _startListening(controller),
              )
            : null,
      ),
    );
  }
}

class ScanExpensePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem lại chi tiêu'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Dữ liệu: ${arguments.toString()}'),
      ),
    );
  }
}
