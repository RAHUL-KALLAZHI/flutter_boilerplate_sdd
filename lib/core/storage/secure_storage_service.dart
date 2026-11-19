import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/exceptions.dart';

/// Contract for encrypted, secure key-value storage.
abstract interface class ISecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<bool> containsKey(String key);
  Future<void> clearAll();

  // Common authentication credentials helpers
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

/// Implementation of [ISecureStorageService] backed by [FlutterSecureStorage].
class SecureStorageService implements ISecureStorageService {
  final FlutterSecureStorage _storage;

  static const String keyAccessToken = 'auth_access_token';
  static const String keyRefreshToken = 'auth_refresh_token';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, stack) {
      throw CacheException('Failed to write to secure storage: $e', stackTrace: stack);
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, stack) {
      throw CacheException('Failed to read from secure storage: $e', stackTrace: stack);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, stack) {
      throw CacheException('Failed to delete from secure storage: $e', stackTrace: stack);
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e, stack) {
      throw CacheException('Failed to check key in secure storage: $e', stackTrace: stack);
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, stack) {
      throw CacheException('Failed to clear secure storage: $e', stackTrace: stack);
    }
  }

  @override
  Future<void> saveAccessToken(String token) => write(keyAccessToken, token);

  @override
  Future<String?> getAccessToken() => read(keyAccessToken);

  @override
  Future<void> saveRefreshToken(String token) => write(keyRefreshToken, token);

  @override
  Future<String?> getRefreshToken() => read(keyRefreshToken);

  @override
  Future<void> clearTokens() async {
    await delete(keyAccessToken);
    await delete(keyRefreshToken);
  }
}
