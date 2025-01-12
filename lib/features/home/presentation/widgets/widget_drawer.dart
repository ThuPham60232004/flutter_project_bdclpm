import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_project_bdclpm/features/load/presentation/pages/upload_page.dart';
import 'package:flutter_project_bdclpm/core/routes/route_names.dart'; 
class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(AuthController.user?.photoURL ?? ''),
                  radius: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  AuthController.user?.displayName ?? 'Guest User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AuthController.user?.email ?? 'example@email.com',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.reviews),
                  title: const Text('Reviews'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payments'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Upload'),
                  onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadPage()),
                      );
                    },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () async {
              await AuthController.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}
