import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used to persist tokens in secure storage.
class _StorageKeys {
  static const accessToken = 'rt_access_token';
  static const refreshToken = 'rt_refresh_token';
  static const userId = 'rt_user_id';
  static const userRole = 'rt_user_role';
}

/// Result returned after a successful login.
class AuthResult {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String role;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
  });
}

/// Handles authentication for all Red Taxi mobile apps.
///
/// Tokens are stored in the device's secure enclave via [FlutterSecureStorage].
/// The [loginEndpoint] and [refreshEndpoint] are absolute URLs supplied by the
/// consuming app so that the shared package remains backend-agnostic.
class AuthService {
  final String loginEndpoint;
  final String refreshEndpoint;
  final FlutterSecureStorage _storage;

  // Internal in-memory cache so callers avoid repeated async storage reads.
  String? _cachedAccessToken;

  AuthService({
    required this.loginEndpoint,
    required this.refreshEndpoint,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Authenticates the user with [email] and [password].
  ///
  /// On success, persists tokens and returns an [AuthResult].
  /// Throws a [StateError] with the server message on failure.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // TODO: replace with real HTTP call via RedTaxiApiClient once wired up.
    // Stub implementation — returns a placeholder result for now.
    throw UnimplementedError(
      'AuthService.login: wire up HTTP call to $loginEndpoint',
    );
  }

  /// Clears all stored tokens and invalidates the in-memory cache.
  Future<void> logout() async {
    _cachedAccessToken = null;
    await Future.wait([
      _storage.delete(key: _StorageKeys.accessToken),
      _storage.delete(key: _StorageKeys.refreshToken),
      _storage.delete(key: _StorageKeys.userId),
      _storage.delete(key: _StorageKeys.userRole),
    ]);
  }

  /// Uses the stored refresh token to obtain a new access token.
  ///
  /// Persists the new token and updates the in-memory cache.
  /// Throws a [StateError] if no refresh token is available.
  Future<String> refreshToken() async {
    final storedRefresh =
        await _storage.read(key: _StorageKeys.refreshToken);
    if (storedRefresh == null) {
      throw StateError(
          'AuthService.refreshToken: no refresh token found — user must log in again.');
    }
    // TODO: replace with real HTTP call via RedTaxiApiClient.
    throw UnimplementedError(
      'AuthService.refreshToken: wire up HTTP call to $refreshEndpoint',
    );
  }

  /// Returns the current access token from cache or secure storage.
  /// Returns [null] if the user is not authenticated.
  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    final stored = await _storage.read(key: _StorageKeys.accessToken);
    _cachedAccessToken = stored;
    return stored;
  }

  /// Returns [true] if a valid access token exists in storage.
  Future<bool> get isAuthenticated async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Returns the persisted user ID, or [null] if not logged in.
  Future<String?> getUserId() =>
      _storage.read(key: _StorageKeys.userId);

  /// Returns the persisted user role (e.g. "driver", "customer", "operator").
  Future<String?> getUserRole() =>
      _storage.read(key: _StorageKeys.userRole);

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  Future<void> _persistTokens(AuthResult result) async {
    _cachedAccessToken = result.accessToken;
    await Future.wait([
      _storage.write(
          key: _StorageKeys.accessToken, value: result.accessToken),
      _storage.write(
          key: _StorageKeys.refreshToken, value: result.refreshToken),
      _storage.write(key: _StorageKeys.userId, value: result.userId),
      _storage.write(key: _StorageKeys.userRole, value: result.role),
    ]);
  }
}
