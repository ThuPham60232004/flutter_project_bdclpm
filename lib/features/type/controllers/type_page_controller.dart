import 'package:flutter/material.dart';

class TypePageController with ChangeNotifier {
  String? selectedOption;
  static const String manualvoice = '/manualvoice';
  static const String scan = '/scan';
  static const String pdfexcel = '/pdfexcel';

  void selectOption(BuildContext context, String? newValue) {
  if (newValue == null || !_isValidRoute(newValue)) return;

  selectedOption = newValue;
  notifyListeners();
  Navigator.pushNamed(context, newValue);
  }


  bool _isValidRoute(String route) {
    return {manualvoice, scan, pdfexcel}.contains(route);
  }
}
