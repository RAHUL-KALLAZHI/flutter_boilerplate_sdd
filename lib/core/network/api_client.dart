import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'environment.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Contract for application HTTP communications.
abstract interface class IApiClient {
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Dio get rawDio;
}

/// Centralized HTTP client implementation wrapping [Dio].
class ApiClient implements IApiClient {
  final Dio _dio;
  final EnvironmentConfig environmentConfig;

  ApiClient({
    required this.environmentConfig,
    Dio? dio,
    AuthInterceptor? authInterceptor,
    LoggingInterceptor? loggingInterceptor,
    ErrorInterceptor? errorInterceptor,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: environmentConfig.apiBaseUrl,
                connectTimeout: environmentConfig.connectTimeout,
                receiveTimeout: environmentConfig.receiveTimeout,
                sendTimeout: environmentConfig.sendTimeout,
                headers: {
                  ApiEndpoints.headerContentType: ApiEndpoints.contentTypeJson,
                  ApiEndpoints.headerAccept: ApiEndpoints.contentTypeJson,
                },
              ),
            ) {
    // Register interceptors in explicit execution order:
    // 1. Auth: attaches token before sending
    // 2. Logging: logs outgoing and incoming calls with masked sensitive fields
    // 3. Error: transforms exceptions into typed AppExceptions
    if (authInterceptor != null) _dio.interceptors.add(authInterceptor);
    _dio.interceptors.add(loggingInterceptor ?? LoggingInterceptor());
    _dio.interceptors.add(errorInterceptor ?? ErrorInterceptor());
  }

  @override
  Dio get rawDio => _dio;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
