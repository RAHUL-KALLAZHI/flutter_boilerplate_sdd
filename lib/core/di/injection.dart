import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Configures dependency injection container across environments.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies([String? environment]) async {
  await getIt.init(environment: environment);
}

/// Clears all registrations in the DI container (useful for test isolation).
Future<void> resetDependencies() async {
  await getIt.reset();
}
