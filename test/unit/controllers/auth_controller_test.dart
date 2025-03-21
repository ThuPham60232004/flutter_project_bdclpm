import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project_bdclpm/features/auth/controllers/auth_controller.dart';
import '../../mocks/mocks.mocks.dart';
import '../../test_config.dart';
import 'dart:convert';

void main() {
  setupTestEnvironment();
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

    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleSignInAuth);
    when(mockGoogleSignInAuth.accessToken).thenReturn("mock_access_token");
    when(mockGoogleSignInAuth.idToken).thenReturn("mock_id_token");
    when(mockFirebaseAuth.signInWithCredential(any))
        .thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.getIdToken()).thenAnswer((_) async => "mock_firebase_token");
    when(mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response(
          jsonEncode({
            "_id": "678cf5b1e729fb9da673725c",
            "firebaseId": "5b28oy5gNSMdvbVQ4JPFEsaNcne2",
            "username": "Thu Pham",
            "email": "phamthianhthu6023789@gmail.com"
          }),
          200,
        ));
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
    when(mockFirebaseAuth.signOut()).thenAnswer((_) async => null);
  });

  group("AuthController - isLoggedIn()", () {
    test("Lấy userId từ SharedPreferences", () async {
      sharedPreferences.setString('userId', "678cf5b1e729fb9da673725c");
      final isLoggedIn = await authController.isLoggedIn();
      print("Lấy userId từ SharedPreferences");
      expect(isLoggedIn, isTrue);
      print(isLoggedIn ? "✅Lấy userId thành công từ SharedPreferences và đăng nhập" : "❌ Chưa đăng nhập");
    });

    test("userId không tồn tại trong SharedPreferences", () async {
      sharedPreferences.remove('userId');
      final isLoggedIn = await authController.isLoggedIn();
      expect(isLoggedIn, isFalse);
      print(isLoggedIn ? "✅ Đã đăng nhập" : "❌ userId không tồn tại trong SharedPreferences nên chưa đăng nhập");
    });
  });

  group("AuthController - Google Sign-In", () {
    test("Người dùng chọn tài khoản Google", () async {
      final user = await authController.loginWithGoogle();
      final isSuccess = user != null;
      expect(isSuccess, isTrue);
      print(isSuccess ? "✅ Người dùng chọn tài khoản Google và đăng nhập thành công" : "❌ Người dùng chọn tài khoản Google và đăng nhập thất bại");
    });

    test("Người dùng hủy đăng nhập", () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
      final user = await authController.loginWithGoogle();
      final isSuccess = user != null;
  
      expect(isSuccess, isFalse);
      print(isSuccess ? "✅ Đăng nhập thành công" : "❌ Người dùng đã hủy đăng nhập nên không đăng nhập được ");
    });

    test("Đăng nhập thất bại khi Google Auth bị lỗi", () async {
      when(mockGoogleSignInAccount.authentication)
          .thenThrow(Exception("Google Auth Error"));
      final user = await authController.loginWithGoogle();
      
      expect(user, isNull);
      print("❌ Đăng nhập thất bại do Google Auth lỗi");
    });

    test("Đăng nhập thất bại ở bước xác thực Firebase", () async {
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenThrow(FirebaseAuthException(code: "error"));
      final user = await authController.loginWithGoogle();

      expect(user, isNull);
      print("❌ Đăng nhập thất bại do Firebase lỗi");
    });

    test("Đăng nhập thất bại khi API backend trả về 401", () async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));
      final user = await authController.loginWithGoogle();

      expect(user, isNull);
      print("❌ Đăng nhập thất bại do API backend từ chối");
    });
  });

  group("AuthController - Token Handling", () {
    test("Lấy được accessToken và idToken", () async {
      final user = await authController.loginWithGoogle();
      final userId = sharedPreferences.getString('userId');

      expect(user, isNotNull);
      expect(userId, "678cf5b1e729fb9da673725c");
      print("✅ Lấy token thành công");
    });

    test("Không lấy được token", () async {
      when(mockGoogleSignInAuth.accessToken).thenReturn(null);
      when(mockGoogleSignInAuth.idToken).thenReturn(null);

      final user = await authController.loginWithGoogle();

      expect(user, isNull);
      print("❌ Không lấy được token");
    });
  });

  group("AuthController - Sign Out", () {
    test("Đăng xuất thành công", () async {
      sharedPreferences.setString('userId', "678cf5b1e729fb9da673725c");
      await authController.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
      expect(sharedPreferences.getString('userId'), isNull);
      print("✅ Đăng xuất thành công");
    });
  });
}
