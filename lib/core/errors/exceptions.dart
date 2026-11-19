/// Base technical exception for all infrastructure-level errors.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorPayload;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.statusCode,
    this.errorPayload,
    this.stackTrace,
  });

  @override
  String toString() =>
      '$runtimeType: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Thrown when remote API/backend responds with a non-2xx status code.
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.errorPayload,
    super.stackTrace,
  });
}

/// Thrown when a local database, disk, or cache operation fails.
class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.statusCode,
    super.errorPayload,
    super.stackTrace,
  });
}

/// Thrown when network connectivity is lost or unreachable.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
    int? statusCode,
    dynamic errorPayload,
    StackTrace? stackTrace,
  ]) : super(
          statusCode: statusCode,
          errorPayload: errorPayload,
          stackTrace: stackTrace,
        );
}

/// Thrown when an HTTP or socket request times out.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException([
    super.message = 'Connection timed out. Please try again.',
    int? statusCode,
    dynamic errorPayload,
    StackTrace? stackTrace,
  ]) : super(
          statusCode: statusCode,
          errorPayload: errorPayload,
          stackTrace: stackTrace,
        );
}

/// Thrown when the server responds with 401 Unauthorized or token is invalid.
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Session expired or unauthorized. Please log in again.',
    super.statusCode = 401,
    super.errorPayload,
    super.stackTrace,
  ]);
}

/// Thrown when the server responds with 403 Forbidden.
class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'Access denied. You do not have permission for this resource.',
    super.statusCode = 403,
    super.errorPayload,
    super.stackTrace,
  ]);
}

/// Thrown when a requested resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.errorPayload,
    super.stackTrace,
  ]);
}

/// Thrown when client or API payload validation fails.
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors = const {},
    super.statusCode = 422,
    super.errorPayload,
    super.stackTrace,
  });
}

/// Catch-all for unexpected runtime or parsing errors.
class UnexpectedException extends AppException {
  const UnexpectedException(
    super.message, {
    super.statusCode,
    super.errorPayload,
    super.stackTrace,
  });
}
