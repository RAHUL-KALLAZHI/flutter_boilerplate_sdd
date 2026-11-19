import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_boilerplate_sdd/core/network/api_client.dart';
import 'package:flutter_boilerplate_sdd/core/network/environment.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('ApiClient', () {
    late EnvironmentConfig config;

    setUp(() {
      config = EnvironmentConfig.dev(apiBaseUrl: 'https://test.lifehub.app');
    });

    test('initializes with BaseOptions matching environment configuration', () {
      final client = ApiClient(environmentConfig: config);

      expect(client.rawDio.options.baseUrl, equals('https://test.lifehub.app'));
      expect(client.rawDio.options.connectTimeout, equals(config.connectTimeout));
      expect(client.rawDio.options.receiveTimeout, equals(config.receiveTimeout));
      expect(client.rawDio.interceptors, isNotEmpty);
    });

    test('get executes through underlying Dio client', () async {
      final mockDio = MockDio();
      when(() => mockDio.interceptors).thenReturn(Interceptors());
      when(() => mockDio.get<String>(
            '/health',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/health'),
            statusCode: 200,
            data: 'OK',
          ));

      final client = ApiClient(environmentConfig: config, dio: mockDio);
      final response = await client.get<String>('/health');

      expect(response.statusCode, equals(200));
      expect(response.data, equals('OK'));
    });
  });
}
