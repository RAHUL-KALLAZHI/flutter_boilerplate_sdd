/// Base Failure class representing domain-level error outcomes.
/// Presentation (BLoC/UI) layers consume Failures rather than raw exceptions.
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  @override
  String toString() =>
      '$runtimeType: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
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
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

/// Request timeout failure.
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out. Please try again.']);
}

/// Authentication or expired session failure.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Session expired. Please log in again.',
    int? statusCode = 401,
  ]) : super(statusCode: statusCode);
}

/// Permission / forbidden failure.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'Access denied. You do not have permission for this action.',
    int? statusCode = 403,
  ]) : super(statusCode: statusCode);
}

/// Resource not found failure.
class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
    int? statusCode = 404,
  ]) : super(statusCode: statusCode);
}

/// Client or server-side input validation failure.
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
    super.statusCode = 422,
  });

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is ValidationFailure &&
      _mapEquals(fieldErrors, other.fieldErrors);

  @override
  int get hashCode => Object.hash(super.hashCode, fieldErrors.toString());

  static bool _mapEquals(Map<String, List<String>> a, Map<String, List<String>> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final listA = a[key]!;
      final listB = b[key]!;
      if (listA.length != listB.length) return false;
      for (int i = 0; i < listA.length; i++) {
        if (listA[i] != listB[i]) return false;
      }
    }
    return true;
  }
}

/// Catch-all for unexpected domain failures.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.statusCode});
}
