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
    );

    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleSignInAuth);
    when(mockGoogleSignInAuth.accessToken).thenReturn(
        "ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334");
    when(mockGoogleSignInAuth.idToken).thenReturn(
        "eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_");
    when(mockFirebaseAuth.signInWithCredential(any))
        .thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn("678cf5b1e729fb9da673725c");
    when(mockUser.getIdToken()).thenAnswer((_) async =>
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph");
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
    test("UC01: Lấy userId từ SharedPreferences", () async {
      sharedPreferences.setString('userId', "678cf5b1e729fb9da673725c");

      final isLoggedIn = await authController.isLoggedIn();
      expect(isLoggedIn, isTrue);
      print(isLoggedIn
          ? "Lấy userId thành công từ SharedPreferences và đăng nhập"
          : "Chưa đăng nhập");
    });

    test("UC02: userId không tồn tại trong SharedPreferences", () async {
      sharedPreferences.remove('userId');

      final isLoggedIn = await authController.isLoggedIn();
      expect(isLoggedIn, isFalse);
      print(isLoggedIn
          ? "Đã đăng nhập"
          : "userId không tồn tại trong SharedPreferences nên chưa đăng nhập");
    });

    group("AuthController - Google Sign-In", () {
      test("UC01: Người dùng chọn tài khoản Google", () async {
        final user = await authController.loginWithGoogle();
        final isSuccess = user != null;
        expect(isSuccess, isTrue);
        print(isSuccess
            ? "Người dùng chọn tài khoản Google thành công"
            : "Người dùng chọn tài khoản Google thất bại");
      });

      test("UC02: Người dùng hủy đăng nhập", () async {
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
        final user = await authController.loginWithGoogle();
        final isSuccess = user != null;

        expect(isSuccess, isFalse);
        print(isSuccess
            ? "Đăng nhập thành công"
            : "Người dùng đã hủy đăng nhập nên không đăng nhập được");
      });
      test("UC03: Kiểm tra coi có accessToken và idToken", () async {
        final user = await authController.loginWithGoogle();
        final accessToken = sharedPreferences.getString('accessToken');
        expect(user, isNotNull);
        expect(accessToken,
            "ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334");
        print(accessToken == null
            ? "Lấy accessToken lỗi"
            : "Lấy accessToken thành công");
      });

      test("UC04: Không lấy được token", () async {
        when(mockGoogleSignInAuth.accessToken).thenReturn(null);
        when(mockGoogleSignInAuth.idToken).thenReturn(null);

        final user = await authController.loginWithGoogle();

        expect(user, isNull);
        print(mockGoogleSignInAuth.accessToken == null &&
                mockGoogleSignInAuth.idToken == null
            ? "Lấy accessToken và idToken lỗi"
            : "Lấy accessToken và idToken thành công");
      });
      test('UC05: Tồn tại firebaseIdToken', () async {
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuth);
        when(mockGoogleSignInAuth.accessToken).thenReturn(
            'ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');
        when(mockGoogleSignInAuth.idToken).thenReturn(
            'eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_');
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.getIdToken()).thenAnswer((_) async =>
            'eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph');
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
            jsonEncode({'_id': '678cf5b1e729fb9da673725c'}), 200));

        final result = await authController.loginWithGoogle();
        print("Tồn tại firebaseIdToken");
        expect(result, isNotNull);
      });

      test('UC06: firebaseIdToken là null', () async {
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuth);
        when(mockGoogleSignInAuth.accessToken).thenReturn(
            'ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');
        when(mockGoogleSignInAuth.idToken).thenReturn(null);

        final result = await authController.loginWithGoogle();
        print("firebaseIdToken là null");
        expect(result, isNull);
      });

      test('UC07: Tồn tại firebaseUser', () async {
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuth);
        when(mockGoogleSignInAuth.accessToken).thenReturn(
            'ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');
        when(mockGoogleSignInAuth.idToken).thenReturn(
            'eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_');
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.getIdToken()).thenAnswer((_) async =>
            'eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph');

        final result = await authController.loginWithGoogle();
        expect(result, isNotNull);
      });

      test('UC08: firebaseUser là null', () async {
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuth);
        when(mockGoogleSignInAuth.accessToken).thenReturn(
            'ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');
        when(mockGoogleSignInAuth.idToken).thenReturn(
            'eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_');
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(null);

        final result = await authController.loginWithGoogle();
        expect(result, isNull);
      });
      test("UC09: Kiểm tra coi có idToken", () async {
        final user = await authController.loginWithGoogle();
        final idToken = sharedPreferences.getString('idToken');
        expect(user, isNotNull);
        expect(idToken,
            "eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_");
        print(idToken == null ? "Lấy  idToken lỗi" : "Lấy idToken thành công");
      });

      test("UC10: Không lấy được idToken", () async {
        when(mockGoogleSignInAuth.idToken).thenReturn(null);

        final user = await authController.loginWithGoogle();

        expect(user, isNull);
        print(mockGoogleSignInAuth.idToken == null
            ? "Lấy idToken lỗi"
            : "Lấy idToken thành công");
      });

      test('UC11: Có _id responseData', () async {
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuth);
        when(mockGoogleSignInAuth.accessToken).thenReturn(
            'ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');
        when(mockGoogleSignInAuth.idToken).thenReturn(
            'eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_n');
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('user_123');
        when(mockUser.getIdToken()).thenAnswer((_) async =>
            'eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph');
        when(mockHttpClient.post(
          Uri.parse(
              'https://backend-bdclpm.onrender.com/api/users/verify-token'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
            jsonEncode({'_id': '678cf5b1e729fb9da673725c'}), 200));

        final user = await authController.loginWithGoogle();
        expect(user, isNotNull);
      });
      test('UC12: Thiếu _id responseData', () async {
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuth);
        when(mockGoogleSignInAuth.accessToken).thenReturn(
            'ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');
        when(mockGoogleSignInAuth.idToken).thenReturn(
            'eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_n');
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('user_123');
        when(mockUser.getIdToken()).thenAnswer((_) async =>
            'eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph');
        when(mockHttpClient.post(
          Uri.parse(
              'https://backend-bdclpm.onrender.com/api/users/verify-token'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode({}), 200));

        final user = await authController.loginWithGoogle();
        expect(user, isNull);
      });
      test("UC13: Đăng nhập thất bại khi API backend trả về 401", () async {
        when(mockHttpClient.post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('Unauthorized', 401));
        final user = await authController.loginWithGoogle();

        expect(user, isNull);
        print("Đăng nhập thất bại do API backend từ chối");
      });
      test('UC14: Đăng nhập thành công khi API backend trả về 200', () async {
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuth);
        when(mockGoogleSignInAuth.accessToken).thenReturn(
            'ya29.a0AeXRPp6YLLEqXVoY4nshdIuNr4_Ni8Q2UuVzpZ7nb96b1UWzKxD9aw9yfSZl_51aq8aC2rLCKDC4X-R_QS5V_vkxpko4XcQJVB2Bdjw_omUe1chZ1Ks2Y_Wy9g7Oxv_jdFQVLijZ_C6wvG74268z7np0XzR6s2ElMU_Inx2DIujjoKijmNn9AHxZT3ddin8kZ6XK2FI3JyoTkQXSPDtEHZLydS99WqdN-IalXiO4pNsuCsJPv199wjWu5Ck_223AwKj28qAsVLxTSoJOAb9yPuYMWNcZjlR1z75rZbQCFmVzeTJXF2wBFjmco-MlRyav-fk3yF0aCgYKAaQSARESFQHGX2MisLPF08wOh8WXOXCFwtAFMg0334');
        when(mockGoogleSignInAuth.idToken).thenReturn(
            'eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMTkzZDQ2NDdhYjRhMzU4NWFhOWIyYjNiNDg0YTg3YWE2OGJiNDIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3NTQ1ODE5OTQ3NDQtbmJhYmVrMGltbHBpamw4cTl2dmFqYXBldGFlMW5kb28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3NTQ1ODE5OTQ3NDQtZWMxcjNqdGIyOG0yaWQwOWsyOWY4b2RrODk3MnVzMWYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MTEwODI2MDY1MzEyMTA5ODgiLCJlbWFpbCI6InBoYW10aGlhbmh0aHU2MDIzNzg5QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImdpdmVuX25hbWUiOiJUaHUiLCJmYW1pbHlfbmFtZSI6IlBoYW0iLCJpYXQiOjE3NDI3NDMzMTcsImV4cCI6MTc0Mjc0NjkxN30.fhIvdP53cuPhRmtt5HnJfY0P-bRSf7ln1RL7RJSBQBOsf3QtCrxEBPXb4AzN07pZRNyfuL53m_ot6F008KMPI7dcCI54dvjV6YMe0CgtlOsp9UpTWIAGRygZe16jku5THSFV7Yn3FRmqMgqEUdGcJ7mvNWoz6eS46bm2v8lWzoB33Iy1GqBhYTynMI0FXaxfodGNCukvJ1U4tvnWBOl8G962XK4eJoSO1zLp6TrXvakrai4hQa_n');
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('user_123');
        when(mockUser.getIdToken()).thenAnswer((_) async =>
            'eyJhbGciOiJSUzI1NiIsImtpZCI6IjMwYjIyMWFiNjU2MTdiY2Y4N2VlMGY4NDYyZjc0ZTM2NTIyY2EyZTQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1IFBoYW0iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jTERPTC1tWmNOMmFFSHF1bmNvb3VvTnNWSUVkaUVKVXZWZEZDa2dodWlwOFRoMnNQWT1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcm9qZWN0LTVlOGQxIiwiYXVkIjoicHJvamVjdC01ZThkMSIsImF1dGhfdGltZSI6MTc0Mjc0MzQ3NSwidXNlcl9pZCI6IjViMjhveTVnTlNNZHZiVlE0SlBGRXNhTmNuZTIiLCJzdWIiOiI1YjI4b3k1Z05TTWR2YlZRNEpQRkVzYU5jbmUyIiwiaWF0IjoxNzQyNzQzNDc1LCJleHAiOjE3NDI3NDcwNzUsImVtYWlsIjoicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDU2MTEwODI2MDY1MzEyMTA5ODgiXSwiZW1haWwiOlsicGhhbXRoaWFuaHRodTYwMjM3ODlAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.uLMSnb5KEeyKhilhwPQuXo89xGIztlHnXFQGSsrZuQLX-Z3DFIuo4qUhw-cx8hTxV3d4ynBBr7aZUlyR_ueYgV428C2r4qQTxI77oXgBjzH2pfkK629jXzLo_tc4BrdGrlcru4BZGOzfNMYhLw6liyWMjN8pkxWWAsfHimSXys37ph');
        when(mockHttpClient.post(
          Uri.parse(
              'https://backend-bdclpm.onrender.com/api/users/verify-token'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
            jsonEncode({'_id': '678cf5b1e729fb9da673725c'}), 200));

        final user = await authController.loginWithGoogle();
        expect(user, isNotNull);
      });
    });

    group("AuthController - Sign Out", () {
      test("Đăng xuất thành công", () async {
        sharedPreferences.setString('userId', "678cf5b1e729fb9da673725c");
        await authController.signOut();

        verify(mockFirebaseAuth.signOut()).called(1);
        verify(mockGoogleSignIn.signOut()).called(1);
        expect(sharedPreferences.getString('userId'), isNull);
        print(sharedPreferences.getString('userId') == null
            ? "Đăng xuất thành công"
            : "Đăng xuất thất bại");
      });
    });
  });
}
