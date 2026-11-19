import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_boilerplate_sdd/core/storage/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureStorageService', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorageService service;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      service = SecureStorageService(storage: mockStorage);
    });

    test('write and read operations succeed', () async {
      when(() => mockStorage.write(key: 'user_id', value: '123'))
          .thenAnswer((_) async {});
      when(() => mockStorage.read(key: 'user_id'))
          .thenAnswer((_) async => '123');

      await service.write('user_id', '123');
      final value = await service.read('user_id');

      expect(value, equals('123'));
      verify(() => mockStorage.write(key: 'user_id', value: '123')).called(1);
      verify(() => mockStorage.read(key: 'user_id')).called(1);
    });

    test('saveAccessToken and getAccessToken manage token key', () async {
      when(() => mockStorage.write(
            key: SecureStorageService.keyAccessToken,
            value: 'jwt_token',
          )).thenAnswer((_) async {});
      when(() => mockStorage.read(key: SecureStorageService.keyAccessToken))
          .thenAnswer((_) async => 'jwt_token');

      await service.saveAccessToken('jwt_token');
      final token = await service.getAccessToken();

      expect(token, equals('jwt_token'));
    });

    test('clearTokens deletes both access and refresh tokens', () async {
      when(() => mockStorage.delete(key: SecureStorageService.keyAccessToken))
          .thenAnswer((_) async {});
      when(() => mockStorage.delete(key: SecureStorageService.keyRefreshToken))
          .thenAnswer((_) async {});

      await service.clearTokens();

      verify(() => mockStorage.delete(key: SecureStorageService.keyAccessToken)).called(1);
      verify(() => mockStorage.delete(key: SecureStorageService.keyRefreshToken)).called(1);
    });

    test('clearAll delegates to deleteAll', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

      await service.clearAll();

      verify(() => mockStorage.deleteAll()).called(1);
    });
  });
}
