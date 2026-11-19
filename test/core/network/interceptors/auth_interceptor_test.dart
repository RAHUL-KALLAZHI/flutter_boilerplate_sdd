import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_boilerplate_sdd/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_boilerplate_sdd/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements ISecureStorageService {}

void main() {
  group('AuthInterceptor', () {
    late MockSecureStorageService mockStorage;
    late AuthInterceptor interceptor;

    setUp(() {
      mockStorage = MockSecureStorageService();
      interceptor = AuthInterceptor(secureStorage: mockStorage);
    });

    test('attaches Authorization header when token exists and requiresAuth is true', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'valid_token_123');

      final options = RequestOptions(path: '/profile');
      final handler = RequestInterceptorHandler();

      RequestOptions? intercepted;
      handler.future.then((opt) => intercepted = opt as RequestOptions);

      await interceptor.onRequest(options, handler);

      expect(intercepted?.headers['Authorization'], equals('Bearer valid_token_123'));
    });

    test('does not attach header when requiresAuth is false', () async {
      final options = RequestOptions(
        path: '/public',
        extra: {AuthInterceptor.extraRequiresAuth: false},
      );
      final handler = RequestInterceptorHandler();

      RequestOptions? intercepted;
      handler.future.then((opt) => intercepted = opt as RequestOptions);

      await interceptor.onRequest(options, handler);

      expect(intercepted?.headers.containsKey('Authorization'), isFalse);
      verifyNever(() => mockStorage.getAccessToken());
    });
  });
}
