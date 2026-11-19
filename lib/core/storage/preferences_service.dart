import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions.dart';

/// Contract for non-sensitive application preferences and key-value settings.
abstract interface class IPreferencesService {
  Future<bool> setString(String key, String value);
  String? getString(String key);

  Future<bool> setBool(String key, bool value);
  bool getBool(String key, {bool defaultValue = false});

  Future<bool> setInt(String key, int value);
  int? getInt(String key);

  Future<bool> setDouble(String key, double value);
  double? getDouble(String key);

  Future<bool> setStringList(String key, List<String> value);
  List<String>? getStringList(String key);

  bool containsKey(String key);
  Future<bool> remove(String key);
  Future<bool> clear();
}

/// Implementation of [IPreferencesService] backed by [SharedPreferences].
class PreferencesService implements IPreferencesService {
  final SharedPreferences _preferences;

  PreferencesService(this._preferences);

  @override
  Future<bool> setString(String key, String value) async {
    try {
      return await _preferences.setString(key, value);
    } catch (e, stack) {
      throw CacheException('Failed to set string in preferences: $e', stackTrace: stack);
    }
  }

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _preferences.setBool(key, value);
    } catch (e, stack) {
      throw CacheException('Failed to set bool in preferences: $e', stackTrace: stack);
    }
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) =>
      _preferences.getBool(key) ?? defaultValue;

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      return await _preferences.setInt(key, value);
    } catch (e, stack) {
      throw CacheException('Failed to set int in preferences: $e', stackTrace: stack);
    }
  }

  @override
  int? getInt(String key) => _preferences.getInt(key);

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _preferences.setDouble(key, value);
    } catch (e, stack) {
      throw CacheException('Failed to set double in preferences: $e', stackTrace: stack);
    }
  }

  @override
  double? getDouble(String key) => _preferences.getDouble(key);

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _preferences.setStringList(key, value);
    } catch (e, stack) {
      throw CacheException('Failed to set string list in preferences: $e', stackTrace: stack);
    }
  }

  @override
  List<String>? getStringList(String key) => _preferences.getStringList(key);

  @override
  bool containsKey(String key) => _preferences.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    try {
      return await _preferences.remove(key);
    } catch (e, stack) {
      throw CacheException('Failed to remove key from preferences: $e', stackTrace: stack);
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _preferences.clear();
    } catch (e, stack) {
      throw CacheException('Failed to clear preferences: $e', stackTrace: stack);
    }
  }
}
