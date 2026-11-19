import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Reusable Mock Adapter for Dio client testing without actual HTTP requests.
class MockDioAdapter implements HttpClientAdapter {
  final Map<String, dynamic Function(RequestOptions options)> _handlers = {};

  void onGet(String path, dynamic Function(RequestOptions options) handler) {
    _handlers['GET:$path'] = handler;
  }

  void onPost(String path, dynamic Function(RequestOptions options) handler) {
    _handlers['POST:$path'] = handler;
  }

  void onPut(String path, dynamic Function(RequestOptions options) handler) {
    _handlers['PUT:$path'] = handler;
  }

  void onDelete(String path, dynamic Function(RequestOptions options) handler) {
    _handlers['DELETE:$path'] = handler;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final key = '${options.method.toUpperCase()}:${options.path}';
    final handler = _handlers[key];

    if (handler != null) {
      final response = handler(options);
      final responseData = response is String ? response : jsonEncode(response);
      return ResponseBody.fromString(
        responseData,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode({'error': 'Not found in MockDioAdapter'}),
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
