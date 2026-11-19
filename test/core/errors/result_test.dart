import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate_sdd/core/errors/failures.dart';
import 'package:flutter_boilerplate_sdd/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Success returns data and isSuccess is true', () {
      const result = Result.success('test_data');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals('test_data'));
      expect(result.failureOrNull, isNull);
    });

    test('FailureResult returns failure and isFailure is true', () {
      const failure = ServerFailure('Server down', statusCode: 500);
      const result = Result<String>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, equals(failure));
    });

    test('when matches branches correctly', () {
      const successResult = Result.success(42);
      final successValue = successResult.when(
        success: (data) => data * 2,
        failure: (_) => 0,
      );
      expect(successValue, equals(84));

      const failureResult = Result<int>.failure(NetworkFailure());
      final failureValue = failureResult.when(
        success: (_) => 'success',
        failure: (f) => f.message,
      );
      expect(failureValue, contains('No internet connection'));
    });

    test('map transforms success and preserves failure', () {
      const successResult = Result.success(10);
      final mappedSuccess = successResult.map((d) => 'Number: $d');
      expect(mappedSuccess, equals(const Result.success('Number: 10')));

      const failureResult = Result<int>.failure(ServerFailure('error'));
      final mappedFailure = failureResult.map((d) => 'Number: $d');
      expect(mappedFailure.isFailure, isTrue);
      expect(mappedFailure.failureOrNull?.message, equals('error'));
    });

    test('mapAsync transforms success asynchronously', () async {
      const successResult = Result.success(5);
      final mapped = await successResult.mapAsync((d) async => d + 10);
      expect(mapped, equals(const Result.success(15)));
    });

    test('equality and hashCode work as expected', () {
      expect(const Result.success('a'), equals(const Result.success('a')));
      expect(
        const Result<int>.failure(NetworkFailure()),
        equals(const Result<int>.failure(NetworkFailure())),
      );
    });
  });
}
