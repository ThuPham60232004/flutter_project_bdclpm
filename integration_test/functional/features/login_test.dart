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
import '../../../test/mocks/mocks.mocks.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
void setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
}

Future<void> main() async {
  setupFirebaseMocks();
  await Firebase.initializeApp();

  late AuthController authController;
  late FirebaseAuth firebaseAuth;
  late GoogleSignIn googleSignIn;
  late http.Client httpClient;
  late SharedPreferences prefs;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockClient mockHttpClient;
  late MockConnectivity mockConnectivity;
  const testUserId = '678cf5b1e729fb9da673725c';
  const testAccessToken = 'ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334';
  const testIdToken = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_';
  const testFirebaseId = '5b28oy5gNSMdvbVQ4JPFEsaNcne2';
  const testUsername = 'Thu Pham';
  const testEmail = 'phamthianhthu6023789@gmail.com';
  setUp(() async {
    HttpOverrides.global = null;
     mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockHttpClient = MockClient();
    mockConnectivity = MockConnectivity();
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

  group('AuthController Tests', () {
    testWidgets('TC24: LoginPage hiển thị và chức năng đăng nhập-với dữ liệu thật',
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
      });
    test('TC25: Abnormal Cases-loginWithGoogle trả về null khi đăng nhập bằng Google bị hủy', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
      expect(await authController.loginWithGoogle(), null);
    });

    test('TC26: loginWithGoogle trả về null khi thiếu mã thông báo', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockAuth = MockGoogleSignInAuthentication();
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn(null);
      when(mockAuth.idToken).thenReturn(null);

      expect(await authController.loginWithGoogle(), null);
    });
  });
  
    test('TC27: loginWithGoogle xử lý lỗi xác thực Firebase', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockAuth = MockGoogleSignInAuthentication();
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn(testAccessToken);
      when(mockAuth.idToken).thenReturn(testIdToken);

      final mockCredential = MockUserCredential();
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(null);

      expect(await authController.loginWithGoogle(), null);
    });

    test('TC28: loginWithGoogle xử lý lỗi phụ trợ 400', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockAuth = MockGoogleSignInAuthentication();
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn(testAccessToken);
      when(mockAuth.idToken).thenReturn(testIdToken);

      final mockUser = MockUser();
      final mockCredential = MockUserCredential();
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph');
      final mockResponse = http.Response(
        jsonEncode({'error': 'Invalid token'}),
        400,
      );
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      expect(await authController.loginWithGoogle(), null);
    });

    test('TC29: loginWithGoogle xử lý lỗi máy chủ 500', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockAuth = MockGoogleSignInAuthentication();
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn(testAccessToken);
      when(mockAuth.idToken).thenReturn(testIdToken);

      final mockUser = MockUser();
      final mockCredential = MockUserCredential();
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph');
      final mockResponse = http.Response(
        'Server Error',
        500,
      );
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      expect(await authController.loginWithGoogle(), null);
    });

  group('LoginPage Tests', () {
    testWidgets('TC30: renders chính xác', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(authController: authController),
        ),
      );

      expect(find.text('Quản lý tài chính của bạn một cách hiệu quả'), findsOneWidget);
      expect(find.text('Đăng nhập với Google'), findsOneWidget);
    });

    testWidgets('TC31: Không hiển thị lỗi mạng', (WidgetTester tester) async {
      
      when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]); 

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(authController: authController),
        ),
      );

      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      await tester.pump();

      await tester.pumpAndSettle(); 
      expect(find.text("Không có kết nối mạng"), findsOneWidget);

    });

    testWidgets('TC32:Điều hướng về nhà khi đăng nhập thành công', (WidgetTester tester) async {
      final mockUser = MockUser();
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => MockGoogleSignInAccount());
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => MockUserCredential());
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode({'_id': '678cf5b1e729fb9da673725c'}), 200));

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
    });

    testWidgets('TC33: Hiển thị lỗi xác thực Firebase', (WidgetTester tester) async {
      when(mockGoogleSignIn.signIn()).thenThrow(FirebaseAuthException(
        message: 'Đã có lỗi xảy ra',
        code: 'ERROR',
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(authController: authController),
        ),
      );

      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      await tester.pump();

      expect(find.textContaining("Đã có lỗi xảy ra"), findsOneWidget);
    });
  });
}
