import 'package:logger/logger.dart';

import 'sensitive_data_masker.dart';

/// Centralized logging contract for LifeHub.
abstract interface class IAppLogger {
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]);
}

/// Concrete implementation of [IAppLogger] wrapping [Logger].
///
/// Automatically redacts sensitive information (tokens, passwords, PII) and
/// filters debug messages in production mode.
class AppLogger implements IAppLogger {
  final Logger _logger;
  final bool isProduction;

  AppLogger({
    Logger? logger,
    this.isProduction = false,
  }) : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 2,
                errorMethodCount: 8,
                lineLength: 100,
                colors: true,
                printEmojis: true,
                dateTimeFormat: DateTimeFormat.dateAndTime,
              ),
              filter: isProduction ? ProductionFilter() : DevelopmentFilter(),
            );

  @override
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (isProduction) return;
    _logger.d(_mask(message), error: _mask(error), stackTrace: stackTrace);
  }

  @override
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(_mask(message), error: _mask(error), stackTrace: stackTrace);
  }

  @override
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(_mask(message), error: _mask(error), stackTrace: stackTrace);
  }

  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(_mask(message), error: _mask(error), stackTrace: stackTrace);
  }

  dynamic _mask(dynamic content) {
    if (content == null) return null;
    return SensitiveDataMasker.maskPayload(content);
  }
}
