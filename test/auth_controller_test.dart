import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/controllers/auth_controller.dart';
import 'auth_controller_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  UserCredential,
  User,
  http.Client,
  SharedPreferences
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockClient mockHttpClient;
  late SharedPreferences sharedPreferences;
  late AuthController authController;

  setUp(() async {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuth = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockHttpClient = MockClient();
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();

    authController = AuthController(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      httpClient: mockHttpClient,
      prefs: sharedPreferences,
    );
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuth);
    when(mockGoogleSignInAuth.accessToken).thenReturn("mock_access_token");
    when(mockGoogleSignInAuth.idToken).thenReturn("mock_id_token");
    when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.getIdToken()).thenAnswer((_) async => "mock_firebase_token");
    when(mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response(
      jsonEncode({
        "_id": "mock_user_id",
        "firebaseId": "mock_firebase_id",
        "username": "mock_username",
        "email": "mock_email"
      }),
      200,
    ));
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
    when(mockFirebaseAuth.signOut()).thenAnswer((_) async => null);
  });

  test("Đăng nhập với Google thành công", () async {
    final user = await authController.loginWithGoogle();
    expect(user, isNotNull);
    expect(sharedPreferences.getString('userId'), "mock_user_id");
  });

  test("Đăng nhập thất bại khi Google Sign-In bị hủy", () async {
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
    final user = await authController.loginWithGoogle();
    expect(user, isNull);
  });

  test("Đăng nhập thất bại khi Firebase xác thực lỗi", () async {
    when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(FirebaseAuthException(code: "error"));
    final user = await authController.loginWithGoogle();
    expect(user, isNull);
  });

  test("Đăng xuất thành công", () async {
    sharedPreferences.setString('userId', "mock_user_id");
    await authController.signOut();
    expect(sharedPreferences.getString('userId'), isNull);
  });
}
