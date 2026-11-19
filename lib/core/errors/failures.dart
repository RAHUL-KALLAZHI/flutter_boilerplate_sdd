/// Base Failure class representing business logic or operational failures.
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType: $message${statusCode != null ? ' ($statusCode)' : ''}';
}

/// Generic server or remote API failure.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

/// Local storage, cache, or database failure.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.statusCode});
}

/// Network connectivity failure.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Client-side validation failure.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
