import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final http.Client httpClient;
  SharedPreferences? _prefs;

  AuthController({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.httpClient,
  });

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get userStream => firebaseAuth.authStateChanges();

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isLoggedIn() async {
    await initPrefs();
    final userId = _prefs?.getString('userId');
    if (userId == null) {
      print('Cảnh báo: Không tìm thấy userId trong SharedPreferences.');
      return false;
    }
    print('User ID tồn tại: $userId');
    return true;
  }

  Future<User?> loginWithGoogle() async {
    try {
      await initPrefs();
      final googleAccount = await googleSignIn.signIn();
      if (googleAccount == null) {
        print('Google Sign-In bị hủy.');
        return null;
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Thiếu accessToken hoặc idToken từ Google.');
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        print('Đăng nhập Firebase thất bại.');
        return null;
      }

      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null) {
        print('Lấy Firebase ID Token thất bại.');
        return null;
      }

      final response = await httpClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/users/verify-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': firebaseIdToken}),
      );

      if (response.statusCode != 200) {
        print('Backend trả về lỗi: ${response.statusCode} - ${response.body}');
        return null;
      }

      final responseData = json.decode(response.body);
      if (!responseData.containsKey('_id')) {
        print('Thiếu _id trong phản hồi từ backend.');
        return null;
      }

      await _prefs?.setString('accessToken', googleAuth.accessToken!);
      await _prefs?.setString('idToken', googleAuth.idToken!);
      await _prefs?.setString('userId', responseData['_id']);
      await _prefs?.setString('firebaseId', responseData['firebaseId'] ?? '');
      await _prefs?.setString('username', responseData['username'] ?? '');
      await _prefs?.setString('email', responseData['email'] ?? '');

      print('Đăng nhập thành công! User ID: ${responseData["_id"]}');
      return firebaseUser;
    } catch (error, stackTrace) {
      print('Lỗi trong quá trình đăng nhập: $error');
      print('StackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    await _prefs?.clear();
  }
}
