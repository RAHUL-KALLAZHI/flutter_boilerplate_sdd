import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate_sdd/core/errors/error_handler.dart';
import 'package:flutter_boilerplate_sdd/core/errors/exceptions.dart';
import 'package:flutter_boilerplate_sdd/core/errors/failures.dart';

void main() {
  group('ErrorHandler.mapToFailure', () {
    test('passes through existing Failure instance', () {
      const failure = ServerFailure('Server down');
      expect(ErrorHandler.mapToFailure(failure), equals(failure));
    });

    test('maps AppException subtypes correctly', () {
      expect(
        ErrorHandler.mapToFailure(const ServerException('error', statusCode: 500)),
        equals(const ServerFailure('error', statusCode: 500)),
      );

      expect(
        ErrorHandler.mapToFailure(const CacheException('cache read error', statusCode: 1)),
        equals(const CacheFailure('cache read error', statusCode: 1)),
      );

      expect(
        ErrorHandler.mapToFailure(const UnauthorizedException()),
        equals(const UnauthorizedFailure()),
      );

      expect(
        ErrorHandler.mapToFailure(const ForbiddenException()),
        equals(const ForbiddenFailure()),
      );

      expect(
        ErrorHandler.mapToFailure(const NotFoundException()),
        equals(const NotFoundFailure()),
      );

      expect(
        ErrorHandler.mapToFailure(
          const ValidationException(
            'Validation failed',
            fieldErrors: {'email': ['Invalid email format']},
          ),
        ),
        equals(
          const ValidationFailure(
            'Validation failed',
            fieldErrors: {'email': ['Invalid email format']},
          ),
        ),
      );
    });

    test('maps DioException with HTTP status code correctly', () {
      final requestOptions = RequestOptions(path: '/test');

      final unauthorizedDio = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'Token expired'},
        ),
      );
      final failure401 = ErrorHandler.mapToFailure(unauthorizedDio);
      expect(failure401, isA<UnauthorizedFailure>());
      expect(failure401.message, equals('Token expired'));
      expect(failure401.statusCode, equals(401));

      final validationDio = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 422,
          data: {
            'message': 'Invalid input',
            'errors': {
              'username': ['Required'],
            },
          },
        ),
      );
      final failure422 = ErrorHandler.mapToFailure(validationDio);
      expect(failure422, isA<ValidationFailure>());
      expect((failure422 as ValidationFailure).fieldErrors['username'], contains('Required'));

      final serverErrorDio = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 503,
        ),
      );
      final failure503 = ErrorHandler.mapToFailure(serverErrorDio);
      expect(failure503, isA<ServerFailure>());
      expect(failure503.statusCode, equals(503));
    });

    test('maps DioException connection errors to NetworkFailure and TimeoutFailure', () {
      final requestOptions = RequestOptions(path: '/test');

      final timeoutDio = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );
      expect(ErrorHandler.mapToFailure(timeoutDio), isA<TimeoutFailure>());

      final connectionDio = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );
      expect(ErrorHandler.mapToFailure(connectionDio), isA<NetworkFailure>());
    });

    test('maps SocketException to NetworkFailure', () {
      const socket = SocketException('Failed host lookup');
      expect(ErrorHandler.mapToFailure(socket), isA<NetworkFailure>());
    });

    test('maps FormatException to ValidationFailure', () {
      const format = FormatException('Bad JSON');
      expect(ErrorHandler.mapToFailure(format), isA<ValidationFailure>());
    });
  });

  group('ErrorHandler.runGuarded', () {
    test('returns Success when block succeeds', () {
      final result = ErrorHandler.runGuarded(() => 100);
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(100));
    });

    test('returns FailureResult when block throws', () {
      final result = ErrorHandler.runGuarded<int>(() {
        throw const SocketException('No route to host');
      });
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('ErrorHandler.runGuardedAsync', () {
    test('returns Success when async block succeeds', () async {
      final result = await ErrorHandler.runGuardedAsync(() async => 'hello');
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals('hello'));
    });

    test('returns FailureResult when async block throws', () async {
      final result = await ErrorHandler.runGuardedAsync<String>(() async {
        throw const ServerException('Database down', statusCode: 500);
      });
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.statusCode, equals(500));
    });
  });
}
