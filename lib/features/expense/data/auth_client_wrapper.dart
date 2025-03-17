import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart' as auth;
class AuthClientWrapper {
  final auth.ServiceAccountCredentials credentials;
  
  AuthClientWrapper(String json)
      : credentials = auth.ServiceAccountCredentials.fromJson(json);

  Future<auth.AutoRefreshingAuthClient> createAuthClient() async {
    return auth.clientViaServiceAccount(
      credentials,
      [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/cloud-vision',
      ],
    );
  }
}
