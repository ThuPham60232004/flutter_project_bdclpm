import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/controllers/auth_controller.dart';
import 'package:iconly/iconly.dart';

import '../../../home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size.width * 0.7),
                  child: Image.asset(
                    'assets/images/h2.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Quản lý tài chính của bạn một cách hiệu quả',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                // Subtitle
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Theo dõi chi tiêu, lập kế hoạch tiết kiệm và đạt được mục tiêu tài chính của bạn với ứng dụng của chúng tôi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const Spacer(),
                // Login Button (Keep original)
                FilledButton.tonalIcon(
                  onPressed: () async {
                    try {
                      final user = await AuthController.loginWithGoogle();
                      if (user != null && mounted) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const HomePage()));
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
