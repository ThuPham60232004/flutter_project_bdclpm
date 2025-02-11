import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/auth/controllers/auth_controller.dart';
import 'package:flutter_project_bdclpm/core/routes/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  AuthController? authController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAuthController();
  }

  Future<void> _initializeAuthController() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authController = AuthController(
        firebaseAuth: FirebaseAuth.instance,
        googleSignIn: GoogleSignIn(),
        httpClient: http.Client(),
        prefs: prefs,
      );
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || authController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildMenuItems(context),
            ),
          ),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<User?>(
      stream: authController!.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: const BoxDecoration(),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  user?.photoURL ?? 'https://via.placeholder.com/150',
                ),
                radius: 40,
              ),
              const SizedBox(height: 10),
              Text(
                user?.displayName ?? 'Guest User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? 'example@email.com',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.add_circle_outline,
        'title': 'Thêm chi tiêu',
        'route': RouteNames.type
      },
      {
        'icon': Icons.history,
        'title': 'LS chi tiêu',
        'route': RouteNames.history
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Thiết lập ngân sách',
        'route': RouteNames.addbudget
      },
      {
        'icon': Icons.category,
        'title': 'Thiết lập category',
        'route': RouteNames.categories
      },
      {
        'icon': Icons.list_alt,
        'title': 'Danh sách ngân sách',
        'route': RouteNames.listbudgets
      },
      {
        'icon': Icons.pie_chart,
        'title': 'Xem biểu đồ chi tiêu',
        'route': RouteNames.categorywise
      },
      {
        'icon': Icons.chat_sharp,
        'title': 'Thu nhập',
        'route': RouteNames.income
      },
      {
        'icon': Icons.history_toggle_off,
        'title': 'LS thu nhập',
        'route': RouteNames.historyincome
      },
      {
        'icon': Icons.spatial_tracking_sharp,
        'title': 'Tổng thu nhập',
        'route': RouteNames.echarts
      },
    ];

    return menuItems.map((item) {
      return ListTile(
        leading: Icon(item['icon'] as IconData,
            color: const Color.fromARGB(255, 0, 0, 0)),
        title: Text(
          item['title'] as String,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          Navigator.pop(context);
          if (item['route'] != null) {
            Navigator.pushNamed(context, item['route'] as String);
          }
        },
      );
    }).toList();
  }

  /// Nút đăng xuất
  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Log Out',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () async {
        await authController!.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
        }
      },
    );
  }
}
