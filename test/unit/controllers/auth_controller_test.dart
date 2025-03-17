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
      expect(isLoggedIn, isTrue);
    });

    test("userId không tồn tại trong SharedPreferences", () async {
      sharedPreferences.remove('userId');
      final isLoggedIn = await authController.isLoggedIn();
      expect(isLoggedIn, isFalse);
    });
  });

  group("AuthController - Google Sign-In", () {
    test("Người dùng chọn tài khoản Google và đăng nhập thành công", () async {
      final user = await authController.loginWithGoogle();
      expect(user, isNotNull);
      expect(sharedPreferences.getString('userId'), "678cf5b1e729fb9da673725c");
    });

    test("Người dùng hủy đăng nhập", () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
      final user = await authController.loginWithGoogle();
      expect(user, isNull);
    });

    test("Đăng nhập thất bại khi Google Sign-In bị hủy", () async {
      when(mockGoogleSignInAccount.authentication)
          .thenThrow(Exception("Google Auth Error"));
      final user = await authController.loginWithGoogle();
      expect(user, isNull);
    });

    test("Đăng nhập thất bại ở bước xác thực Firebase", () async {
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenThrow(FirebaseAuthException(code: "error"));
      final user = await authController.loginWithGoogle();
      expect(user, isNull);
    });

    test("Đăng nhập thất bại khi gọi API backend", () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));
      final user = await authController.loginWithGoogle();
      expect(user, isNull);
    });

    test("Lỗi ngoại lệ trong quá trình đăng nhập", () async {
      when(mockGoogleSignIn.signIn()).thenThrow(Exception("Unexpected Error"));
      final user = await authController.loginWithGoogle();
      expect(user, isNull);
    });
  });
  group("AuthController - Token Handling", () {
    test("Lấy được accessToken và idToken", () async {
      when(mockGoogleSignInAuth.accessToken).thenReturn("mock_access_token");
      when(mockGoogleSignInAuth.idToken).thenReturn("mock_id_token");

      final user = await authController.loginWithGoogle();

      expect(user, isNotNull);
      expect(sharedPreferences.getString('userId'), "678cf5b1e729fb9da673725c");
    });

    test("Không lấy được token", () async {
      when(mockGoogleSignInAuth.accessToken).thenReturn(null);
      when(mockGoogleSignInAuth.idToken).thenReturn(null);

      final user = await authController.loginWithGoogle();

      expect(user, isNull);
    });
  });
  group("AuthController - Firebase User", () {
    test("firebaseUser hợp lệ", () async {
      when(mockUserCredential.user).thenReturn(mockUser);

      final user = await authController.loginWithGoogle();

      expect(user, isNotNull);
      expect(sharedPreferences.getString('userId'), "678cf5b1e729fb9da673725c");
    });

    test("firebaseUser là null", () async {
      when(mockUserCredential.user).thenReturn(null);

      final user = await authController.loginWithGoogle();

      expect(user, isNull);
    });
  });
  group("AuthController - idToken", () {
    test("Lấy được idToken", () async {
      when(mockUser.getIdToken()).thenAnswer((_) async => "mock_id_token");

      final user = await authController.loginWithGoogle();

      expect(user, isNotNull);
      expect(sharedPreferences.getString('userId'), "678cf5b1e729fb9da673725c");
    });

    test("idToken là null", () async {
      when(mockUser.getIdToken()).thenAnswer((_) async => null);

      final user = await authController.loginWithGoogle();

      expect(user, isNull);
    });
  });

  group("AuthController - Sign Out", () {
    test("Đăng xuất thành công", () async {
      sharedPreferences.setString('userId', "678cf5b1e729fb9da673725c");

      await authController.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
      expect(sharedPreferences.getString('userId'), isNull);
    });
  });
}
