import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_project_bdclpm/features/income/controllers/expense_statistics_controller.dart';

class ExpenseStatisticsScreen extends StatefulWidget {
  @override
  _ExpenseStatisticsScreenState createState() =>
      _ExpenseStatisticsScreenState();
}

class _ExpenseStatisticsScreenState extends State<ExpenseStatisticsScreen> {
  final ExpenseStatisticsController _controller = ExpenseStatisticsController();

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    await _controller.layThongKe();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thống kê chi tiêu - thu nhập',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _controller.getDangTai()
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _xayDungKhungSoDu(),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _xayDungTheThongKe(
                              'Thu nhập',
                              _controller.getThuNhap(),
                              Colors.green,
                              FontAwesomeIcons.moneyBillTrendUp)),
                      SizedBox(width: 10),
                      Expanded(
                          child: _xayDungTheThongKe(
                              'Chi tiêu',
                              _controller.getChiTieu(),
                              Colors.red,
                              FontAwesomeIcons.moneyBillWave)),
                    ],
                  ),
                  SizedBox(height: 20),
                  _xayDungBieuDoTron(
                      _controller.getThuNhap(), _controller.getChiTieu())
                ],
              ),
            ),
    );
  }

  Widget _xayDungKhungSoDu() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 245, 176, 66),
            const Color.fromARGB(255, 210, 25, 25)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.wallet,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số dư',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '${_controller.getSoDu().toString()} VND',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _xayDungTheThongKe(
      String nhan, int soTien, Color mauSac, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: mauSac.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mauSac.withOpacity(0.2),
            ),
            child: Icon(icon, color: mauSac, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            nhan,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '${soTien.toString()} VND',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: mauSac,
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungBieuDoTron(int thuNhap, int chiTieu) {
    double tong = (thuNhap + chiTieu).toDouble();

    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: tong > 0
          ? Column(
              children: [
                Text(
                  "Tổng Quan Tài Chính",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: thuNhap.toDouble(),
                          color: Colors.green.shade400,
                          title:
                              "${((thuNhap / tong) * 100).toStringAsFixed(1)}%",
                          radius: 70,
                          titleStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        PieChartSectionData(
                          value: chiTieu.toDouble(),
                          color: Colors.red.shade400,
                          title:
                              "${((chiTieu / tong) * 100).toStringAsFixed(1)}%",
                          radius: 70,
                          titleStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                      ],
                      centerSpaceRadius: 45,
                      sectionsSpace: 6,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem("Thu Nhập", Colors.green.shade400),
                    SizedBox(width: 16),
                    _buildLegendItem("Chi Tiêu", Colors.red.shade400),
                  ],
                ),
              ],
            )
          : Center(
              child: Text(
                "Không có dữ liệu",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}