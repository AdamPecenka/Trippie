import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract final class AuthStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

class AuthService {
  AuthService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: AuthStorageKeys.accessToken, value: accessToken);
    await _storage.write(key: AuthStorageKeys.refreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: AuthStorageKeys.accessToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AuthStorageKeys.refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}