import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate_sdd/core/logging/sensitive_data_masker.dart';

void main() {
  group('SensitiveDataMasker', () {
    test('maskString redacts Bearer tokens', () {
      const input = 'Authorization: Bearer secret_jwt_token_123456';
      final masked = SensitiveDataMasker.maskString(input);

      expect(masked, equals('Authorization: Bearer ***MASKED***'));
    });

    test('maskMap redacts sensitive keys regardless of case', () {
      final input = {
        'username': 'john_doe',
        'password': 'SuperSecretPassword!',
        'PASSWORD': 'DuplicatePassword',
        'access_token': 'eyJh...xyz',
        'apiKey': 'key_987654321',
        'metadata': {
          'client_secret': 'shhhh',
          'nested_ok': 'visible_value',
        },
      };

      final masked = SensitiveDataMasker.maskMap(input);

      expect(masked['username'], equals('john_doe'));
      expect(masked['password'], equals('***MASKED***'));
      expect(masked['PASSWORD'], equals('***MASKED***'));
      expect(masked['access_token'], equals('***MASKED***'));
      expect(masked['apiKey'], equals('***MASKED***'));
      expect((masked['metadata'] as Map)['client_secret'], equals('***MASKED***'));
      expect((masked['metadata'] as Map)['nested_ok'], equals('visible_value'));
    });

    test('maskPayload redacts raw JSON string', () {
      const jsonString = '{"email":"test@example.com","password":"mypassword123"}';
      final masked = SensitiveDataMasker.maskPayload(jsonString) as String;

      expect(masked, contains('"password":"***MASKED***"'));
      expect(masked, isNot(contains('mypassword123')));
    });

    test('maskList redacts sensitive fields in list of maps', () {
      final list = [
        {'id': 1, 'token': 'abc'},
        {'id': 2, 'token': 'xyz'},
      ];

      final masked = SensitiveDataMasker.maskList(list);
      expect((masked[0] as Map)['token'], equals('***MASKED***'));
      expect((masked[1] as Map)['token'], equals('***MASKED***'));
    });
  });
}
