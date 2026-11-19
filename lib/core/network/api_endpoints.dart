/// Centralized API constants, headers, and endpoint routes for LifeHub.
class ApiEndpoints {
  const ApiEndpoints._();

  // Header Keys
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerApiKey = 'x-api-key';

  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';

  // Default Timeouts
  static const Duration defaultConnectTimeout = Duration(seconds: 15);
  static const Duration defaultReceiveTimeout = Duration(seconds: 15);
  static const Duration defaultSendTimeout = Duration(seconds: 15);

  // Authentication Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // User Profile
  static const String userProfile = '/user/me';

  // System
  static const String systemHealth = '/health';
}
