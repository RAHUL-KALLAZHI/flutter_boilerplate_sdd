import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';
import '../../logging/sensitive_data_masker.dart';

/// Dio interceptor that formats and logs HTTP requests, responses, and errors,
/// automatically masking authorization tokens, passwords, and sensitive keys.
class LoggingInterceptor extends Interceptor {
  final IAppLogger _logger;

  LoggingInterceptor({IAppLogger? logger}) : _logger = logger ?? AppLogger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri.toString();
    final method = options.method.toUpperCase();
    final maskedHeaders = SensitiveDataMasker.maskMap(options.headers);
    final maskedData = SensitiveDataMasker.maskPayload(options.data);
    final maskedQuery = SensitiveDataMasker.maskMap(options.queryParameters);

    _logger.debug(
      '🌐 HTTP REQUEST [$method] ➔ $uri\n'
      'Headers: $maskedHeaders\n'
      'Query: $maskedQuery\n'
      'Body: $maskedData',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final uri = response.requestOptions.uri.toString();
    final method = response.requestOptions.method.toUpperCase();
    final statusCode = response.statusCode;
    final maskedData = SensitiveDataMasker.maskPayload(response.data);

    _logger.debug(
      '✅ HTTP RESPONSE [$statusCode] ➔ [$method] $uri\n'
      'Body: $maskedData',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final uri = err.requestOptions.uri.toString();
    final method = err.requestOptions.method.toUpperCase();
    final statusCode = err.response?.statusCode;
    final maskedResponse = SensitiveDataMasker.maskPayload(err.response?.data);

    _logger.warning(
      '❌ HTTP ERROR [${statusCode ?? 'NO_STATUS'}] ➔ [$method] $uri\n'
      'Type: ${err.type}\n'
      'Message: ${err.message}\n'
      'Response: $maskedResponse',
      err.error,
      err.stackTrace,
    );

    handler.next(err);
  }
}
