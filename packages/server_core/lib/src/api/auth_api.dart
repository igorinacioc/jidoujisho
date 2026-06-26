import '../models/server_models.dart';

/// Authentication API contract.
///
/// Implementations handle login/logout against a specific server type.
abstract class AuthApi {
  /// Authenticates with username and password.
  ///
  /// Returns an [AuthResult] with access token and user info.
  /// Throws on invalid credentials or network failure.
  Future<AuthResult> authenticateByName(String username, String password);

  /// Logs out the current session.
  Future<void> logout();
}
