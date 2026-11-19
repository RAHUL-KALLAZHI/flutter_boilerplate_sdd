import 'package:flutter_boilerplate_sdd/core/database/app_database.dart';
import 'package:flutter_boilerplate_sdd/core/di/injection.dart';
import 'package:flutter_boilerplate_sdd/core/logging/app_logger.dart';
import 'package:flutter_boilerplate_sdd/core/network/api_client.dart';
import 'package:flutter_boilerplate_sdd/core/storage/preferences_service.dart';
import 'package:flutter_boilerplate_sdd/core/storage/secure_storage_service.dart';

import 'mock_services.dart';

/// Helper to configure GetIt with test doubles for feature testing.
Future<void> setupTestInjection({
  IApiClient? apiClient,
  AppDatabase? appDatabase,
  ISecureStorageService? secureStorage,
  IPreferencesService? preferences,
  IAppLogger? logger,
}) async {
  await resetDependencies();

  getIt.registerSingleton<IApiClient>(apiClient ?? MockApiClient());
  getIt.registerSingleton<AppDatabase>(appDatabase ?? MockAppDatabase());
  getIt.registerSingleton<ISecureStorageService>(secureStorage ?? MockSecureStorageService());
  getIt.registerSingleton<IPreferencesService>(preferences ?? MockPreferencesService());
  getIt.registerSingleton<IAppLogger>(logger ?? MockAppLogger());
}
