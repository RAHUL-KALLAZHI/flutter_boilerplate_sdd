import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate_sdd/core/errors/exceptions.dart';
import 'package:flutter_boilerplate_sdd/core/network/interceptors/error_interceptor.dart';

class TestErrorHandler extends ErrorInterceptorHandler {
  DioException? capturedError;

  @override
  void next(DioException err) {
    capturedError = err;
  }

  @override
  void reject(DioException err, [bool callNext = false]) {
    capturedError = err;
  }
}

void main() {
  group('ErrorInterceptor', () {
    late ErrorInterceptor interceptor;

    setUp(() {
      interceptor = ErrorInterceptor();
    });

    test('transforms 401 HTTP error to UnauthorizedException', () {
      final requestOptions = RequestOptions(path: '/user');
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'Session expired'},
        ),
      );

      final handler = TestErrorHandler();
      interceptor.onError(err, handler);

      expect(handler.capturedError?.error, isA<UnauthorizedException>());
      expect((handler.capturedError?.error as UnauthorizedException).message, equals('Session expired'));
    });

    test('transforms 422 HTTP error to ValidationException with field errors', () {
      final requestOptions = RequestOptions(path: '/register');
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 422,
          data: {
            'message': 'Validation failed',
            'errors': {
              'email': ['Must be a valid email'],
            },
          },
        ),
      );

      final handler = TestErrorHandler();
      interceptor.onError(err, handler);

      expect(handler.capturedError?.error, isA<ValidationException>());
      final validation = handler.capturedError?.error as ValidationException;
      expect(validation.fieldErrors['email'], contains('Must be a valid email'));
    });

    test('transforms connectionTimeout to RequestTimeoutException', () {
      final requestOptions = RequestOptions(path: '/timeout');
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final handler = TestErrorHandler();
      interceptor.onError(err, handler);

      expect(handler.capturedError?.error, isA<RequestTimeoutException>());
    });
  });
}
