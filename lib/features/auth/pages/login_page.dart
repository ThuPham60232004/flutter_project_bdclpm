import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/auth/controllers/auth_controller.dart';
import 'package:iconly/iconly.dart';
import '../../home/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController;

  const LoginPage({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Image.asset(
                    'assets/images/h2.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Quản lý tài chính của bạn một cách hiệu quả',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Theo dõi chi tiêu, lập kế hoạch tiết kiệm và đạt được mục tiêu tài chính của bạn với ứng dụng của chúng tôi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    try {
                      final user = await authController.loginWithGoogle();
                      if (user != null && context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const HomePage(key: Key('homePage'))),
                        );
                      }
                    } on FirebaseAuthException catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error.message ?? "Đã có lỗi xảy ra"),
                      ));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error.toString()),
                      ));
                    }
                  },
                  icon: const Icon(IconlyLight.login),
                  key: Key('google_sign_in_button'),
                  label: const Text("Đăng nhập với Google"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
