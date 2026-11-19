import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../storage/preferences_service.dart';
import '../../storage/secure_storage_service.dart';

@module
abstract class StorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  @lazySingleton
  ISecureStorageService secureStorageService(FlutterSecureStorage storage) =>
      SecureStorageService(storage: storage);

  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  @lazySingleton
  IPreferencesService preferencesService(SharedPreferences prefs) =>
      PreferencesService(prefs);
}
