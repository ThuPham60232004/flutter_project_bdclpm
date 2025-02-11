import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/controllers/auth_controller.dart';
import 'package:iconly/iconly.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthController? authController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAuthController();
  }

  /// Hàm khởi tạo `AuthController` đúng cách
  Future<void> _initializeAuthController() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authController = AuthController(
        firebaseAuth: FirebaseAuth.instance,
        googleSignIn: GoogleSignIn(),
        httpClient: http.Client(),
        prefs: prefs, // Đã khởi tạo đúng
      );
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || authController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
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
                      final user = await authController!.loginWithGoogle();
                      if (user != null && mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const HomePage()),
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
