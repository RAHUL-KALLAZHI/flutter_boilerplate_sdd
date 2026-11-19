enum EnvironmentType {
  dev,
  staging,
  prod,
}

/// Centralized environment configuration for LifeHub.
///
/// Can be parameterized via `--dart-define=ENVIRONMENT=prod` or `--dart-define=API_BASE_URL=https://...`
class EnvironmentConfig {
  final EnvironmentType environment;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final String appName;

  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
    this.appName = 'LifeHub',
  });

  /// Pre-configured Development environment.
  factory EnvironmentConfig.dev({String? apiBaseUrl}) {
    return EnvironmentConfig(
      environment: EnvironmentType.dev,
      apiBaseUrl: apiBaseUrl ?? 'https://dev-api.lifehub.app/api/v1',
      appName: 'LifeHub (Dev)',
    );
  }

  /// Pre-configured Staging environment.
  factory EnvironmentConfig.staging({String? apiBaseUrl}) {
    return EnvironmentConfig(
      environment: EnvironmentType.staging,
      apiBaseUrl: apiBaseUrl ?? 'https://staging-api.lifehub.app/api/v1',
      appName: 'LifeHub (Staging)',
    );
  }

  /// Pre-configured Production environment.
  factory EnvironmentConfig.prod({String? apiBaseUrl}) {
    return EnvironmentConfig(
      environment: EnvironmentType.prod,
      apiBaseUrl: apiBaseUrl ?? 'https://api.lifehub.app/api/v1',
      appName: 'LifeHub',
    );
  }

  /// Detects environment from compile-time defines (`--dart-define=ENVIRONMENT=...`).
  factory EnvironmentConfig.fromEnvironment() {
    const envString = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    const customBaseUrl = String.fromEnvironment('API_BASE_URL');

    final baseUrl = customBaseUrl.isNotEmpty ? customBaseUrl : null;

    switch (envString.toLowerCase()) {
      case 'prod':
      case 'production':
        return EnvironmentConfig.prod(apiBaseUrl: baseUrl);
      case 'staging':
      case 'stage':
        return EnvironmentConfig.staging(apiBaseUrl: baseUrl);
      case 'dev':
      case 'development':
      default:
        return EnvironmentConfig.dev(apiBaseUrl: baseUrl);
    }
  }

  bool get isProduction => environment == EnvironmentType.prod;
  bool get isStaging => environment == EnvironmentType.staging;
  bool get isDevelopment => environment == EnvironmentType.dev;
}
