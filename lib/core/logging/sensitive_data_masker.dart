import 'dart:convert';

/// Utility class for redacting sensitive fields, authentication tokens, and PII
/// from log outputs and network interceptors.
class SensitiveDataMasker {
  const SensitiveDataMasker._();

  static const String maskPlaceholder = '***MASKED***';

  /// Field keys that must always be masked (case-insensitive).
  static const Set<String> _sensitiveKeys = {
    'password',
    'pass',
    'token',
    'access_token',
    'refresh_token',
    'auth_token',
    'authorization',
    'id_token',
    'secret',
    'client_secret',
    'api_key',
    'apikey',
    'x-api-key',
    'credit_card',
    'card_number',
    'cvv',
    'cvc',
    'pin',
    'ssn',
    'cookie',
    'set-cookie',
  };

  /// Regex pattern to detect and mask Bearer authorization tokens in strings.
  static final RegExp _bearerPattern = RegExp(
    r'(Bearer\s+)[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );

  /// Regex pattern to detect potential email addresses in strings and mask user part.
  static final RegExp _emailPattern = RegExp(
    r'([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+\.[a-zA-Z]{2,5})',
  );

  /// Masks any string content containing known tokens or patterns.
  static String maskString(String input) {
    if (input.isEmpty) return input;

    // Mask Bearer tokens
    var output = input.replaceAllMapped(_bearerPattern, (match) {
      return '${match.group(1)}$maskPlaceholder';
    });

    return output;
  }

  /// Recursively masks sensitive keys and values in a Map (such as headers or JSON payloads).
  static Map<String, dynamic> maskMap(Map<dynamic, dynamic> input) {
    final result = <String, dynamic>{};

    for (final entry in input.entries) {
      final key = entry.key.toString();
      final keyLower = key.toLowerCase();
      final value = entry.value;

      if (_isSensitiveKey(keyLower)) {
        result[key] = maskPlaceholder;
      } else if (value is Map) {
        result[key] = maskMap(value);
      } else if (value is List) {
        result[key] = maskList(value);
      } else if (value is String) {
        result[key] = maskString(value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  /// Recursively masks elements in a list.
  static List<dynamic> maskList(List<dynamic> input) {
    return input.map((item) {
      if (item is Map) {
        return maskMap(item);
      } else if (item is List) {
        return maskList(item);
      } else if (item is String) {
        return maskString(item);
      }
      return item;
    }).toList();
  }

  /// Automatically inspects dynamic data (Map, List, JSON String, or Object) and returns masked representation.
  static dynamic maskPayload(dynamic payload) {
    if (payload == null) return null;

    if (payload is Map) {
      return maskMap(payload);
    }

    if (payload is List) {
      return maskList(payload);
    }

    if (payload is String) {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map || decoded is List) {
          final masked = maskPayload(decoded);
          return jsonEncode(masked);
        }
      } catch (_) {
        // Not JSON, mask as raw string
      }
      return maskString(payload);
    }

    return payload;
  }

  static bool _isSensitiveKey(String key) {
    if (_sensitiveKeys.contains(key)) return true;
    for (final sensitive in _sensitiveKeys) {
      if (key.contains(sensitive)) return true;
    }
    return false;
  }
}
