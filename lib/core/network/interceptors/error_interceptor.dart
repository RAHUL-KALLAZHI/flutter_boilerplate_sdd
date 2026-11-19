import 'dart:io';

import 'package:dio/dio.dart';

import '../../errors/exceptions.dart';

/// Dio interceptor that intercepts raw [DioException]s and transforms their `.error`
/// property into an application-specific [AppException].
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapToAppException(err);

    // Forward a modified DioException containing the typed AppException
    final transformed = err.copyWith(
      error: appException,
      message: appException.message,
    );

    handler.next(transformed);
  }

  static AppException _mapToAppException(DioException err) {
    final response = err.response;
    final statusCode = response?.statusCode;

    if (statusCode != null) {
      final message = _extractErrorMessage(response) ??
          err.message ??
          'HTTP Error $statusCode';

      switch (statusCode) {
        case 401:
          return UnauthorizedException(
            message,
            statusCode,
            response?.data,
            err.stackTrace,
          );
        case 403:
          return ForbiddenException(
            message,
            statusCode,
            response?.data,
            err.stackTrace,
          );
        case 404:
          return NotFoundException(
            message,
            statusCode,
            response?.data,
            err.stackTrace,
          );
        case 422:
          final fieldErrors = _extractFieldErrors(response);
          return ValidationException(
            message,
            fieldErrors: fieldErrors,
            statusCode: statusCode,
            errorPayload: response?.data,
            stackTrace: err.stackTrace,
          );
        default:
          if (statusCode >= 500) {
            return ServerException(
              'Server error ($statusCode). Please try again later.',
              statusCode: statusCode,
              errorPayload: response?.data,
              stackTrace: err.stackTrace,
            );
          }
          return ServerException(
            message,
            statusCode: statusCode,
            errorPayload: response?.data,
            stackTrace: err.stackTrace,
          );
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RequestTimeoutException(
          'Network connection timed out. Please check your internet connection.',
          null,
          err.error,
          err.stackTrace,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          'Could not reach server. Please check your network connection.',
          null,
          err.error,
          err.stackTrace,
        );
      case DioExceptionType.badCertificate:
        return ServerException(
          'Security certificate validation failed.',
          errorPayload: err.error,
          stackTrace: err.stackTrace,
        );
      case DioExceptionType.cancel:
        return UnexpectedException(
          'Request was cancelled.',
          stackTrace: err.stackTrace,
        );
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          return NetworkException(
            'No internet connection.',
            null,
            err.error,
            err.stackTrace,
          );
        }
        return UnexpectedException(
          err.message ?? 'An unexpected network error occurred.',
          errorPayload: err.error,
          stackTrace: err.stackTrace,
        );
      default:
        return ServerException(
          err.message ?? 'HTTP network communication failed.',
          errorPayload: err.error,
          stackTrace: err.stackTrace,
        );
    }
  }

  static String? _extractErrorMessage(Response? response) {
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
}
