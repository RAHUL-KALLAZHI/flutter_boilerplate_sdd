import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate_sdd/core/logging/app_logger.dart';
import 'package:flutter_boilerplate_sdd/core/network/interceptors/logging_interceptor.dart';

class CapturingLogger implements IAppLogger {
  final List<String> debugMessages = [];
  final List<String> warningMessages = [];

  @override
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    debugMessages.add(message.toString());
  }

  @override
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {}

  @override
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    warningMessages.add(message.toString());
  }

  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {}
}

void main() {
  group('LoggingInterceptor', () {
    late CapturingLogger logger;
    late LoggingInterceptor interceptor;

    setUp(() {
      logger = CapturingLogger();
      interceptor = LoggingInterceptor(logger: logger);
    });

    test('onRequest masks Authorization header and password in body', () {
      final options = RequestOptions(
        path: '/login',
        method: 'POST',
        headers: {'Authorization': 'Bearer secret_token_xyz'},
        data: {'username': 'testuser', 'password': 'mySecretPassword'},
      );

      final handler = RequestInterceptorHandler();
      interceptor.onRequest(options, handler);

      expect(logger.debugMessages, isNotEmpty);
      final log = logger.debugMessages.first;
      expect(log, contains('Bearer ***MASKED***'));
      expect(log, contains('***MASKED***'));
      expect(log, isNot(contains('mySecretPassword')));
    });

    test('onError logs warning with masked payload', () {
      final options = RequestOptions(path: '/user');
      final dioException = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 400,
          data: {'error': 'Bad request', 'token': 'sensitive_123'},
        ),
      );

      final handler = ErrorInterceptorHandler();
      interceptor.onError(dioException, handler);

      expect(logger.warningMessages, isNotEmpty);
      final log = logger.warningMessages.first;
      expect(log, contains('HTTP ERROR [400]'));
      expect(log, contains('***MASKED***'));
      expect(log, isNot(contains('sensitive_123')));
    });
  });
}
