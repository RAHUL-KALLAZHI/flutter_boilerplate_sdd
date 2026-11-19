import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_boilerplate_sdd/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_boilerplate_sdd/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements ISecureStorageService {}

class TestRequestHandler extends RequestInterceptorHandler {
  RequestOptions? capturedOptions;

  @override
  void next(RequestOptions requestOptions) {
    capturedOptions = requestOptions;
  }
}

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
      final handler = TestRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.capturedOptions?.headers['Authorization'], equals('Bearer valid_token_123'));
    });

    test('does not attach header when requiresAuth is false', () async {
      final options = RequestOptions(
        path: '/public',
        extra: {AuthInterceptor.extraRequiresAuth: false},
      );
      final handler = TestRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.capturedOptions?.headers.containsKey('Authorization'), isFalse);
      verifyNever(() => mockStorage.getAccessToken());
    });
  });
}
