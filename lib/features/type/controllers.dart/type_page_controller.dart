import 'package:flutter/material.dart';

class TypePageController with ChangeNotifier {
  String? selectedOption;
  static const String manualvoice = '/manualvoice';
  static const String scan = '/scan';
  static const String pdfexcel = '/pdfexcel';

  void selectOption(BuildContext context, String? newValue) {
    if (newValue != null) {
      selectedOption = newValue;
      notifyListeners();
      Navigator.pushNamed(context, newValue);
    }
  }
}
