import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:flutter_boilerplate_sdd/core/logging/app_logger.dart';

class TestLogOutput extends LogOutput {
  final List<OutputEvent> events = [];

  @override
  void output(OutputEvent event) {
    events.add(event);
  }
}

void main() {
  group('AppLogger', () {
    late TestLogOutput testOutput;
    late Logger innerLogger;

    setUp(() {
      testOutput = TestLogOutput();
      innerLogger = Logger(
        output: testOutput,
        printer: SimplePrinter(printTime: false, colors: false),
        filter: DevelopmentFilter(),
      );
    });

    test('masks sensitive strings in logs', () {
      final logger = AppLogger(logger: innerLogger, isProduction: false);

      logger.info('User password is: mysecretpassword123');

      expect(testOutput.events, isNotEmpty);
      final logLines = testOutput.events.first.lines.join('\n');
      // Password key masking
      expect(logLines, contains('***MASKED***'));
    });

    test('masks bearer token in logs', () {
      final logger = AppLogger(logger: innerLogger, isProduction: false);

      logger.warning('Sending Bearer token: Bearer abc123def456');

      expect(testOutput.events, isNotEmpty);
      final logLines = testOutput.events.first.lines.join('\n');
      expect(logLines, contains('Bearer ***MASKED***'));
    });

    test('suppresses debug logs when isProduction is true', () {
      final prodLogger = AppLogger(logger: innerLogger, isProduction: true);

      prodLogger.debug('Debug message that should not print in prod');
      expect(testOutput.events, isEmpty);

      prodLogger.error('Critical failure');
      expect(testOutput.events, isNotEmpty);
    });
  });
}
