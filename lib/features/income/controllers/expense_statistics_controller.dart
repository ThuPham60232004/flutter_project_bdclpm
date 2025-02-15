import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ExpenseStatisticsController {
  int thuNhap = 0;
  int chiTieu = 0;
  int soDu = 0;
  bool dangTai = true;

  Future<void> layThongKe() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final url =
        'https://backend-bdclpm.onrender.com/api/expenses/statistics/$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      thuNhap = data['income'];
      chiTieu = data['expense'];
      soDu = thuNhap - chiTieu;
      dangTai = false;
    }
  }

  int getThuNhap() => thuNhap;
  int getChiTieu() => chiTieu;
  int getSoDu() => soDu;
  bool getDangTai() => dangTai;
}