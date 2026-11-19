import 'dart:async';

import 'package:dio/dio.dart';

import '../../storage/secure_storage_service.dart';
import '../api_endpoints.dart';

/// Interceptor that attaches the Bearer access token to authenticated outgoing requests
/// and coordinates thread-safe token refresh upon receiving HTTP 401 Unauthorized responses.
class AuthInterceptor extends QueuedInterceptor {
  final ISecureStorageService _secureStorage;
  final Dio? _refreshDio;
  final Future<String?> Function()? _onRefreshToken;
  final VoidCallback? _onSessionExpired;

  static const String extraRequiresAuth = 'requiresAuth';

  AuthInterceptor({
    required ISecureStorageService secureStorage,
    Dio? refreshDio,
    Future<String?> Function()? onRefreshToken,
    VoidCallback? onSessionExpired,
  })  : _secureStorage = secureStorage,
        _refreshDio = refreshDio,
        _onRefreshToken = onRefreshToken,
        _onSessionExpired = onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra[extraRequiresAuth] as bool? ?? true;

    if (requiresAuth && !options.headers.containsKey(ApiEndpoints.headerAuthorization)) {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiEndpoints.headerAuthorization] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final is401 = response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains(ApiEndpoints.authRefresh);

    if (is401 && !isRefreshCall && _onRefreshToken != null) {
      try {
        final newToken = await _onRefreshToken();

        if (newToken != null && newToken.isNotEmpty) {
          await _secureStorage.saveAccessToken(newToken);

          // Retry the failed request with the new access token
          final requestOptions = err.requestOptions;
          requestOptions.headers[ApiEndpoints.headerAuthorization] = 'Bearer $newToken';

          final dio = _refreshDio ?? Dio();
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Token refresh failed completely; clear session
        await _secureStorage.clearTokens();
        _onSessionExpired?.call();
      }
    }

    handler.next(err);
  }
}

typedef VoidCallback = void Function();
