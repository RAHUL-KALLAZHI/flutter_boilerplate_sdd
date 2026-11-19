import 'failures.dart';

/// Functional Result container representing either a successful [data] of type [T]
/// or a domain [failure].
///
/// Leverages Dart 3 sealed class for exhaustive pattern matching and clean switch expressions:
/// ```dart
/// final outcome = await repository.fetchUser();
/// switch (outcome) {
///   case Success(:final data):
///     print('User: $data');
///   case FailureResult(:final failure):
///     print('Error: ${failure.message}');
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Create a successful [Result] containing [data].
  const factory Result.success(T data) = Success<T>;

  /// Create a failed [Result] containing [failure].
  const factory Result.failure(Failure failure) = FailureResult<T>;

  /// Returns `true` if the result is [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if the result is [FailureResult].
  bool get isFailure => this is FailureResult<T>;

  /// Returns the underlying data if successful, otherwise `null`.
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        FailureResult() => null,
      };

  /// Returns the underlying failure if failed, otherwise `null`.
  Failure? get failureOrNull => switch (this) {
        Success() => null,
        FailureResult(:final failure) => failure,
      };

  /// Pattern-match over the two states with explicit callbacks.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) =>
      switch (this) {
        Success(:final data) => success(data),
        FailureResult(:final failure: final f) => failure(f),
      };

  /// Transform the data using [transform] if successful, preserving failure otherwise.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(:final data) => Result.success(transform(data)),
        FailureResult(:final failure) => Result.failure(failure),
      };

  /// Asynchronously transform the data using [transform] if successful.
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success(:final data) => Result.success(await transform(data)),
      FailureResult(:final failure) => Result.failure(failure),
    };
  }
}

/// Successful branch of [Result].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() => 'Result.success($data)';
}

/// Failure branch of [Result].
final class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'Result.failure($failure)';
}
