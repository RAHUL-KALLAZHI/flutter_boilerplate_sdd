import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../logging/app_logger.dart';
import '../../network/api_client.dart';
import '../../network/environment.dart';
import '../../network/interceptors/auth_interceptor.dart';
import '../../network/interceptors/error_interceptor.dart';
import '../../network/interceptors/logging_interceptor.dart';
import '../../storage/secure_storage_service.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  EnvironmentConfig get environmentConfig => EnvironmentConfig.fromEnvironment();

  @lazySingleton
  IAppLogger appLogger(EnvironmentConfig env) =>
      AppLogger(isProduction: env.isProduction);

  @lazySingleton
  LoggingInterceptor loggingInterceptor(IAppLogger logger) =>
      LoggingInterceptor(logger: logger);

  @lazySingleton
  ErrorInterceptor get errorInterceptor => ErrorInterceptor();

  @lazySingleton
  AuthInterceptor authInterceptor(ISecureStorageService secureStorage) =>
      AuthInterceptor(secureStorage: secureStorage);

  @lazySingleton
  IApiClient apiClient(
    EnvironmentConfig env,
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
    ErrorInterceptor errorInterceptor,
  ) =>
      ApiClient(
        environmentConfig: env,
        authInterceptor: authInterceptor,
        loggingInterceptor: loggingInterceptor,
        errorInterceptor: errorInterceptor,
      );

  @lazySingleton
  Dio dio(IApiClient client) => client.rawDio;
}
