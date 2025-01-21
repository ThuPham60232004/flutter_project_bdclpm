import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static User? user = FirebaseAuth.instance.currentUser;
  static Stream<User?> get userStream =>
      FirebaseAuth.instance.authStateChanges();

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
      if (firebaseUser == null) {
        print("Firebase authentication failed, user is null.");
        return null;
      }
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        print("Firebase ID token is null.");
        return null;
      }

      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken();

        final response = await http.post(
          Uri.parse(
              'https://backend-bdclpm.onrender.com/api/users/verify-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'token': idToken,
          }),
        );
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final userId = responseData['_id'];
          final firebaseId = responseData['firebaseId'];
          final username = responseData['username'];
          final email = responseData['email'];
          if (userId == null ||
              firebaseId == null ||
              username == null ||
              email == null) {
            print("One or more required fields are missing from the response");
            return null;
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          await prefs.setString('firebaseId', firebaseId);
          await prefs.setString('username', username);
          await prefs.setString('email', email);

          print("Thông tin người dùng đã được gửi và lưu thành công");
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

    // Clear user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('firebaseId');
    await prefs.remove('username');
    await prefs.remove('email');
  }
}
