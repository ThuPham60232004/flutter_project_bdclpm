import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project_bdclpm/features/auth/controllers/auth_controller.dart';
import 'package:flutter_project_bdclpm/features/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/home/pages/home_page.dart';
import 'dart:io';

// Tạo mock Firebase app
void setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
}

Future<void> main() async {
  // Khởi tạo Firebase mock trước khi chạy test
  setupFirebaseMocks();
  await Firebase.initializeApp();

  late AuthController authController;
  late FirebaseAuth firebaseAuth;
  late GoogleSignIn googleSignIn;
  late http.Client httpClient;
  late SharedPreferences prefs;

  setUp(() async {
    HttpOverrides.global = null;
    firebaseAuth = FirebaseAuth.instance;
    googleSignIn = GoogleSignIn();
    httpClient = http.Client();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    authController = AuthController(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      httpClient: httpClient,
    );
  });

  tearDown(() async {
    try {
      await authController.signOut();
      await prefs.clear();
    } catch (e) {
      print('Lỗi khi dọn dẹp: $e');
    }
  });

  group('AuthController Functional Tests với dữ liệu thật', () {
    testWidgets(
      'LoginPage hiển thị và chức năng đăng nhập',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LoginPage(authController: authController),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Đăng nhập với Google'), findsOneWidget);
        await tester.tap(find.byKey(Key('google_sign_in_button')));
        await tester.pumpAndSettle(Duration(seconds: 15));
        expect(find.byType(HomePage), findsOneWidget);
      },
    );
  });
}
