/// Base application exception.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType: $message${statusCode != null ? ' ($statusCode)' : ''}';
}

/// Thrown when remote server call fails.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Thrown when local cache or DB operation fails.
class CacheException extends AppException {
  const CacheException(super.message, {super.statusCode});
}

/// Thrown when network connection is unreachable.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failed']);
}
