import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController {
  static User? user = FirebaseAuth.instance.currentUser;

  static Future<User?> loginWithGoogle() async {
    try {
      final googleAccount = await GoogleSignIn().signIn();
      if (googleAccount == null) return null;

      final googleAuth = await googleAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Lấy idToken từ Firebase
        final idToken = await firebaseUser.getIdToken();

        // Gửi thông tin tới backend
        final response = await http.post(
          Uri.parse('http://10.21.10.135:4000/api/users/verify-token'), // Đổi URL sang địa chỉ IP cục bộ
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'token': idToken,
          }),
        );

        if (response.statusCode == 200) {
          print("Thông tin người dùng đã được gửi thành công");
        } else {
          print("Lỗi gửi thông tin: ${response.body}");
        }
      }

      return firebaseUser;
    } catch (error) {
      print("Lỗi trong quá trình đăng nhập Google: $error");
      return null;
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
