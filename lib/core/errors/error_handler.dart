import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';
import 'result.dart';

/// Centralized utility for translating raw technical exceptions into domain [Failure] instances.
class ErrorHandler {
  const ErrorHandler._();

  /// Converts any exception or error into a domain-level [Failure].
  static Failure mapToFailure(dynamic error, [StackTrace? stackTrace]) {
    if (error is Failure) {
      return error;
    }

    if (error is AppException) {
      return _mapAppExceptionToFailure(error);
    }

    if (error is DioException) {
      return _mapDioExceptionToFailure(error);
    }

    if (error is SocketException) {
      return const NetworkFailure();
    }

    if (error is TimeoutException) {
      return const TimeoutFailure();
    }

    if (error is FormatException) {
      return ValidationFailure('Invalid data format: ${error.message}');
    }

    return UnexpectedFailure(
      error?.toString() ?? 'An unexpected error occurred.',
    );
  }

  static Failure _mapAppExceptionToFailure(AppException exception) {
    return switch (exception) {
      ServerException(:final message, :final statusCode) =>
        ServerFailure(message, statusCode: statusCode),
      CacheException(:final message, :final statusCode) =>
        CacheFailure(message, statusCode: statusCode),
      NetworkException(:final message) => NetworkFailure(message),
      RequestTimeoutException(:final message) => TimeoutFailure(message),
      UnauthorizedException(:final message, :final statusCode) =>
        UnauthorizedFailure(message, statusCode: statusCode),
      ForbiddenException(:final message, :final statusCode) =>
        ForbiddenFailure(message, statusCode: statusCode),
      NotFoundException(:final message, :final statusCode) =>
        NotFoundFailure(message, statusCode: statusCode),
      ValidationException(:final message, :final fieldErrors, :final statusCode) =>
        ValidationFailure(message, fieldErrors: fieldErrors, statusCode: statusCode),
      UnexpectedException(:final message, :final statusCode) =>
        UnexpectedFailure(message, statusCode: statusCode),
      _ => UnexpectedFailure(exception.message, statusCode: exception.statusCode),
    };
  }

  static Failure _mapDioExceptionToFailure(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;

    // Check for specific HTTP status codes first
    if (statusCode != null) {
      final message = _extractMessageFromResponse(response) ??
          exception.message ??
          'HTTP Error $statusCode';

      switch (statusCode) {
        case 401:
          return UnauthorizedFailure(message, statusCode: statusCode);
        case 403:
          return ForbiddenFailure(message, statusCode: statusCode);
        case 404:
          return NotFoundFailure(message, statusCode: statusCode);
        case 422:
          final errors = _extractFieldErrors(response);
          return ValidationFailure(message, fieldErrors: errors, statusCode: statusCode);
        default:
          if (statusCode >= 500) {
            return ServerFailure(
              'Server error ($statusCode). Please try again later.',
              statusCode: statusCode,
            );
          }
          return ServerFailure(message, statusCode: statusCode);
      }
    }

    // Check DioExceptionType
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.cancel:
        return const UnexpectedFailure('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ServerFailure('Invalid server SSL certificate.');
      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return const NetworkFailure();
        }
        return UnexpectedFailure(exception.message ?? 'Unknown network error.');
      default:
        return ServerFailure(exception.message ?? 'Network request failed.');
    }
  }

  static String? _extractMessageFromResponse(Response? response) {
    final data = response?.data;
    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;
      if (data['detail'] is String) return data['detail'] as String;
    }
    return null;
  }

  static Map<String, List<String>> _extractFieldErrors(Response? response) {
    final data = response?.data;
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      final result = <String, List<String>>{};
      for (final entry in errors.entries) {
        if (entry.value is List) {
          result[entry.key.toString()] =
              (entry.value as List).map((e) => e.toString()).toList();
        } else if (entry.value is String) {
          result[entry.key.toString()] = [entry.value.toString()];
        }
      }
      return result;
    }
    return const {};
  }

  /// Safely executes an async operation, capturing all exceptions into a [Result<T>].
  static Future<Result<T>> runGuardedAsync<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final value = await operation();
      return Result.success(value);
    } catch (e, stack) {
      return Result.failure(mapToFailure(e, stack));
    }
  }

  /// Safely executes a sync operation, capturing all exceptions into a [Result<T>].
  static Result<T> runGuarded<T>(T Function() operation) {
    try {
      final value = operation();
      return Result.success(value);
    } catch (e, stack) {
      return Result.failure(mapToFailure(e, stack));
    }
  }
}
