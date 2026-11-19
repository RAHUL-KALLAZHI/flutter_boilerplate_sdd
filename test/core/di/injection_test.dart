import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_boilerplate_sdd/core/database/app_database.dart';
import 'package:flutter_boilerplate_sdd/core/di/injection.dart';
import 'package:flutter_boilerplate_sdd/core/logging/app_logger.dart';
import 'package:flutter_boilerplate_sdd/core/network/api_client.dart';
import 'package:flutter_boilerplate_sdd/core/network/environment.dart';
import 'package:flutter_boilerplate_sdd/core/router/app_router.dart';
import 'package:flutter_boilerplate_sdd/core/storage/preferences_service.dart';
import 'package:flutter_boilerplate_sdd/core/storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dependency Injection', () {
    setUp(() async {
      await resetDependencies();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await resetDependencies();
    });

    test('configureDependencies registers and resolves all core services', () async {
      await configureDependencies('test');

      expect(getIt.isRegistered<EnvironmentConfig>(), isTrue);
      expect(getIt.isRegistered<IAppLogger>(), isTrue);
      expect(getIt.isRegistered<ISecureStorageService>(), isTrue);
      expect(getIt.isRegistered<IPreferencesService>(), isTrue);
      expect(getIt.isRegistered<IApiClient>(), isTrue);
      expect(getIt.isRegistered<AppDatabase>(), isTrue);
      expect(getIt.isRegistered<AppRouter>(), isTrue);

      final logger1 = getIt<IAppLogger>();
      final logger2 = getIt<IAppLogger>();
      expect(identical(logger1, logger2), isTrue);

      final client1 = getIt<IApiClient>();
      final client2 = getIt<IApiClient>();
      expect(identical(client1, client2), isTrue);
    });

    test('resetDependencies clears container registrations cleanly', () async {
      await configureDependencies('test');
      expect(getIt.isRegistered<EnvironmentConfig>(), isTrue);

      await resetDependencies();
      expect(getIt.isRegistered<EnvironmentConfig>(), isFalse);
    });
  });
}
