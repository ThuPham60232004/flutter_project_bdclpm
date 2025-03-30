import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project_bdclpm/features/auth/controllers/auth_controller.dart';
import 'package:flutter_project_bdclpm/features/auth/pages/login_page.dart';
import 'package:mockito/mockito.dart';
import '../../test/mocks/mocks.mocks.dart';
import 'dart:convert';
import 'package:iconly/iconly.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockClient mockClient;
  late MockSharedPreferences mockPrefs;
  late AuthController authController;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockClient = MockClient();
    mockPrefs = MockSharedPreferences();

    authController = AuthController(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      httpClient: mockClient,
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: LoginPage(authController: authController),
    );
  }

  group('Kiểm thử giao diện LoginPage', () {
    testWidgets('Nên hiển thị đầy đủ các thành phần giao diện chính',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Quản lý tài chính của bạn một cách hiệu quả'),
          findsOneWidget);
      expect(
        find.text(
            'Theo dõi chi tiêu, lập kế hoạch tiết kiệm và đạt được mục tiêu tài chính của bạn với ứng dụng của chúng tôi.'),
        findsOneWidget,
      );
      expect(find.text('Đăng nhập với Google'), findsOneWidget);
      expect(find.byIcon(IconlyLight.login), findsOneWidget);
      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
    });

    testWidgets('Nên gọi loginWithGoogle khi nhấn nút',
        (WidgetTester tester) async {
      final mockUser = MockUser();
      final mockAccount = MockGoogleSignInAccount();
      final mockAuth = MockGoogleSignInAuthentication();
      final mockCredential = MockUserCredential();

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn('mock_access_token');
      when(mockAuth.idToken).thenReturn('mock_id_token');
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => 'firebase_id_token');
      when(mockUser.uid).thenReturn('firebase_uid');
      when(mockClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/users/verify-token'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({
              '_id': 'user123',
              'firebaseId': 'firebase_uid',
              'username': 'testuser',
              'email': 'test@example.com'
            }),
            200,
          ));
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      await tester.pump();
      verify(mockGoogleSignIn.signIn()).called(1);
    });
  });
}
