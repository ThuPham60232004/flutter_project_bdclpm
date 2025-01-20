import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_project_bdclpm/core/routes/route_names.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      stream: AuthController.userStream, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); 
        }

        final user = snapshot.data;

        return Container(
          padding: const EdgeInsets.only(top: 50, bottom: 20),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user?.photoURL ?? 'https://via.placeholder.com/150'),
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
      {'icon': Icons.notifications_active, 'title': 'Notifications', 'route': null},
      {'icon': Icons.star_rate, 'title': 'Reviews', 'route': null},
      {'icon': Icons.account_balance_wallet, 'title': 'Payments', 'route': null},
      {'icon': Icons.dashboard, 'title': 'Thêm chi tiêu', 'route': RouteNames.type},
      {'icon': Icons.history, 'title': 'LS chi tiêu', 'route': RouteNames.history},
    ];

    return menuItems.map((item) {
      return ListTile(
        leading: Icon(item['icon'] as IconData),
        title: Text(item['title'] as String),
        onTap: () {
          Navigator.pop(context);
          if (item['route'] != null) {
            Navigator.pushNamed(context, item['route'] as String);
          }
        },
      );
    }).toList();
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Log Out'),
      onTap: () async {
        await AuthController.signOut();
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      },
    );
  }
}
