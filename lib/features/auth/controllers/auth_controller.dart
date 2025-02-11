import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final http.Client httpClient;
  final SharedPreferences prefs;

  AuthController({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.httpClient,
    required this.prefs,
  });

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get userStream => firebaseAuth.authStateChanges();

  Future<bool> isLoggedIn() async {
    final userId = prefs.getString('userId');
    return userId != null;
  }

  Future<User?> loginWithGoogle() async {
    try {
      final googleAccount = await googleSignIn.signIn();
      if (googleAccount == null) return null;

      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) return null;

      final response = await httpClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/users/verify-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await prefs.setString('userId', responseData['_id'] ?? '');
        await prefs.setString('firebaseId', responseData['firebaseId'] ?? '');
        await prefs.setString('username', responseData['username'] ?? '');
        await prefs.setString('email', responseData['email'] ?? '');
        return firebaseUser;
      }
    } catch (error) {
      return null;
    }
    return null;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    await prefs.clear();
  }
}
