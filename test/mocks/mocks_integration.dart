import 'package:mockito/annotations.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
  MockSpec<User>(),
  MockSpec<UserCredential>(),
  MockSpec<http.Client>(),
  MockSpec<SharedPreferences>(),
  MockSpec<NavigatorObserver>(),
  MockSpec<NavigatorState>(),
  MockSpec<BuildContext>(),
])
void main() {}
