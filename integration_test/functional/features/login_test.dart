import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/auth/controllers/auth_controller.dart';
import 'package:flutter_project_bdclpm/features/auth/pages/login_page.dart';
import 'package:flutter_project_bdclpm/features/home/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../test/mocks/mocks_integration.mocks.dart';
import 'package:http/http.dart' as http;

Future<void> waitForWidget(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 5)}) async {
  final int maxTries = timeout.inMilliseconds ~/ 100;
  int tries = 0;
  while (tries < maxTries) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    tries++;
  }
  throw TestFailure('Widget not found within ${timeout.inSeconds} seconds');
}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late AuthController authController;
  late MockClient mockHttpClient;
  late MockSharedPreferences mockSharedPreferences;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockHttpClient = MockClient();
    mockSharedPreferences = MockSharedPreferences();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockNavigatorObserver = MockNavigatorObserver();

    authController = AuthController(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      httpClient: mockHttpClient,
    );

    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuthentication);
    when(mockGoogleSignInAuthentication.idToken).thenReturn('eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_');
    when(mockGoogleSignInAuthentication.accessToken).thenReturn('ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');

    when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);

    when(mockUser.uid).thenReturn("678cf5b1e729fb9da673725c");
    when(mockUser.email).thenReturn("phamthianhthu6023789@gmail.com");
    when(mockUser.displayName).thenReturn("Thu Pham");
    when(mockUser.photoURL).thenReturn("https://example.com/avatar.jpg");
    when(mockUser.getIdToken()).thenAnswer((_) async => "eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph");

    when(mockHttpClient.post(
      Uri.parse("https://backend-bdclpm.onrender.com/api/users/verify-token"),
      headers: anyNamed("headers"),
      body: anyNamed("body"),
      encoding: anyNamed("encoding"),
    )).thenAnswer((_) async => http.Response('{"status":"success", "_id": "678cf5b1e729fb9da673725c"}', 200));

    when(mockNavigatorObserver.didPush(any, any)).thenAnswer((invocation) {
      print('Navigated to: ${invocation.positionalArguments[0]}');
    });
  });
  testWidgets('Navigates to HomePage after successful login', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginPage(authController: authController),
      routes: {'/home': (context) => HomePage()},
      navigatorObservers: [mockNavigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);

    await waitForWidget(tester, find.byKey(const Key('google_sign_in_button')));
    final signInButton = find.byKey(const Key('google_sign_in_button'));
    expect(signInButton, findsOneWidget);

    await tester.tap(signInButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    verify(mockGoogleSignIn.signIn()).called(1);
    verify(mockNavigatorObserver.didPush(any, any));

    await waitForWidget(tester, find.byType(HomePage));
    expect(find.byType(HomePage), findsOneWidget);
  });
}