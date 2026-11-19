// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../database/app_database.dart' as _i427;
import '../../logging/app_logger.dart' as _i974;
import '../../network/api_client.dart' as _i910;
import '../../network/environment.dart' as _i971;
import '../../network/interceptors/auth_interceptor.dart' as _i784;
import '../../network/interceptors/error_interceptor.dart' as _i48;
import '../../network/interceptors/logging_interceptor.dart' as _i688;
import '../../router/app_router.dart' as _i290;
import '../../router/router_listenable.dart' as _i858;
import '../../storage/preferences_service.dart' as _i722;
import '../../storage/secure_storage_service.dart' as _i856;
import 'modules/database_module.dart' as _i406;
import 'modules/network_module.dart' as _i935;
import 'modules/router_module.dart' as _i970;
import 'modules/storage_module.dart' as _i1049;

extension GetItInjectableX on _i174.GetIt {
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    final storageModule = _$StorageModule();
    final databaseModule = _$DatabaseModule();
    final routerModule = _$RouterModule();

    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i971.EnvironmentConfig>(
        () => networkModule.environmentConfig);
    gh.lazySingleton<_i48.ErrorInterceptor>(
        () => networkModule.errorInterceptor);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => storageModule.secureStorage);
    gh.lazySingleton<_i856.ISecureStorageService>(() =>
        storageModule.secureStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i784.AuthInterceptor>(() =>
        networkModule.authInterceptor(gh<_i856.ISecureStorageService>()));
    gh.lazySingleton<_i974.IAppLogger>(
        () => networkModule.appLogger(gh<_i971.EnvironmentConfig>()));
    gh.lazySingleton<_i688.LoggingInterceptor>(() =>
        networkModule.loggingInterceptor(gh<_i974.IAppLogger>()));
    gh.lazySingleton<_i910.IApiClient>(() => networkModule.apiClient(
          gh<_i971.EnvironmentConfig>(),
          gh<_i784.AuthInterceptor>(),
          gh<_i688.LoggingInterceptor>(),
          gh<_i48.ErrorInterceptor>(),
        ));
    gh.lazySingleton<_i361.Dio>(
        () => networkModule.dio(gh<_i910.IApiClient>()));
    gh.lazySingleton<_i722.IPreferencesService>(() =>
        storageModule.preferencesService(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i427.AppDatabase>(() => databaseModule.appDatabase);
    gh.lazySingleton<_i858.RouterListenable>(
        () => routerModule.routerListenable);
    gh.lazySingleton<_i290.AppRouter>(
        () => routerModule.appRouter(gh<_i858.RouterListenable>()));
    return this;
  }
}

class _$NetworkModule extends _i935.NetworkModule {}

class _$StorageModule extends _i1049.StorageModule {}

class _$DatabaseModule extends _i406.DatabaseModule {}

class _$RouterModule extends _i970.RouterModule {}
