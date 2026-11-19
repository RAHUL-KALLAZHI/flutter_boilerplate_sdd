import 'package:mocktail/mocktail.dart';
import 'package:flutter_boilerplate_sdd/core/database/app_database.dart';
import 'package:flutter_boilerplate_sdd/core/logging/app_logger.dart';
import 'package:flutter_boilerplate_sdd/core/network/api_client.dart';
import 'package:flutter_boilerplate_sdd/core/router/router_listenable.dart';
import 'package:flutter_boilerplate_sdd/core/storage/preferences_service.dart';
import 'package:flutter_boilerplate_sdd/core/storage/secure_storage_service.dart';

class MockApiClient extends Mock implements IApiClient {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSecureStorageService extends Mock implements ISecureStorageService {}

class MockPreferencesService extends Mock implements IPreferencesService {}

class MockAppLogger extends Mock implements IAppLogger {}

class MockRouterListenable extends Mock implements RouterListenable {}
