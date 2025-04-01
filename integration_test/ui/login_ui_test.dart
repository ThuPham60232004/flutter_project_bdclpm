import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
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
    testWidgets('Kiểm thử giao diện LoginPage',
        (WidgetTester tester) async {
      final mockUser = MockUser();
      final mockAccount = MockGoogleSignInAccount();
      final mockAuth = MockGoogleSignInAuthentication();
      final mockCredential = MockUserCredential();

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn('ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');
      when(mockAuth.idToken).thenReturn('eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_');
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph');
      when(mockUser.uid).thenReturn('678cf5b1e729fb9da673725c');
      when(mockClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/users/verify-token'),
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
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

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
      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      await tester.pump();
      verify(mockGoogleSignIn.signIn()).called(1);
    });
  });
}
