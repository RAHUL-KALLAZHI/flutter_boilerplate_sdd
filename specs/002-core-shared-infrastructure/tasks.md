# Tasks: 002-core-shared-infrastructure

**Input**: Design documents from `/specs/002-core-shared-infrastructure/` (spec.md, plan.md)  
**Status**: Ready for Review  
**Prerequisites**: plan.md (approved), spec.md (approved), Constitution v2.0.0  

---

## Task List Summary

- Total Tasks: 27
- Phases: 9
- Coverage: 8 Core Infrastructure Domains (Networking, DI, Database, Storage, Routing, Errors, Logging, Testing)

---

## Phase 1: Setup & Dependencies

### T001: Configure core infrastructure dependencies in pubspec.yaml
- **Status**: [x] Completed
- **Scope**: Add all approved third-party libraries and dev dependencies required for shared infrastructure.
- **Dependencies**: None
- **Expected Deliverables**:
  - Modified [pubspec.yaml](file:///Users/rahul/Documents/flutter%20projects/flutter_boilerplate_sdd/pubspec.yaml) with `dio`, `get_it`, `injectable`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `flutter_secure_storage`, `shared_preferences`, `go_router`, `flutter_bloc`, `logger`, `build_runner`, `injectable_generator`, `drift_dev`, `mocktail`.
- **Test Requirements**: Run `flutter pub get` cleanly without version conflicts.
- **Acceptance Criteria**: All required packages resolve cleanly and are ready for imports.

---

## Phase 2: Common Error Abstractions & Result Handling

### T002: Implement technical exception hierarchy
- **Status**: [x] Completed
- **Scope**: Define standard `AppException` and concrete technical exceptions for remote, local, network, and unexpected failures.
- **Dependencies**: T001
- **Expected Deliverables**:
  - [lib/core/errors/exceptions.dart](file:///Users/rahul/Documents/flutter%20projects/flutter_boilerplate_sdd/lib/core/errors/exceptions.dart) (`AppException`, `ServerException`, `CacheException`, `NetworkException`, `UnauthorizedException`, `NotFoundException`).
- **Test Requirements**: Verify exceptions retain message, status codes, and stack traces.
- **Acceptance Criteria**: Exception classes conform to Dart sound null safety and include formatting representations.

### T003: Implement domain failure abstractions
- **Status**: [x] Completed
- **Scope**: Define domain-level `Failure` classes ensuring domain and presentation layers never import raw technical exceptions.
- **Dependencies**: T001
- **Expected Deliverables**:
  - [lib/core/errors/failures.dart](file:///Users/rahul/Documents/flutter%20projects/flutter_boilerplate_sdd/lib/core/errors/failures.dart) (`Failure`, `ServerFailure`, `CacheFailure`, `NetworkFailure`, `UnauthorizedFailure`, `ValidationFailure`).
- **Test Requirements**: Value equality and user-facing message resolution.
- **Acceptance Criteria**: Domain failures contain clean user-facing error messages and HTTP status codes when applicable.

### T004: Implement sealed Result container
- **Status**: [x] Completed
- **Scope**: Build a native Dart 3 sealed `Result<T>` class (`Success<T>`, `FailureResult<T>`) for functional error propagation.
- **Dependencies**: T003
- **Expected Deliverables**:
  - `lib/core/errors/result.dart` (Sealed `Result<T>` with pattern matching, `when`, `map`, and `fold` helpers).
- **Test Requirements**: Unit test in `test/core/errors/result_test.dart` testing both success and failure branches.
- **Acceptance Criteria**: Supports Dart 3 switch expressions and exhaustive type matching without third-party monad packages.

### T005: Implement centralized ErrorHandler and unit tests
- **Status**: [x] Completed
- **Scope**: Build error translation utility that converts raw `DioException`, `SqliteException`, or unknown errors into domain `Failure` instances.
- **Dependencies**: T002, T003, T004
- **Expected Deliverables**:
  - `lib/core/errors/error_handler.dart`
  - `test/core/errors/error_handler_test.dart`
- **Test Requirements**: Test mapping of various DioExceptionTypes and SQLite errors into respective `Failure` objects.
- **Acceptance Criteria**: 100% test pass rate for all mapped error conditions.

---

## Phase 3: Logging Infrastructure & Sensitive Data Masking

### T006: Implement SensitiveDataMasker utility
- **Status**: [x] Completed
- **Scope**: Build regular-expression based data redactor for passwords, tokens, API keys, and PII.
- **Dependencies**: T001
- **Expected Deliverables**:
  - `lib/core/logging/sensitive_data_masker.dart`
  - `test/core/logging/sensitive_data_masker_test.dart`
- **Test Requirements**: Unit test with simulated strings, JSON payloads, and header maps containing sensitive keywords.
- **Acceptance Criteria**: Sensitive substrings are replaced with `***MASKED***` without breaking JSON formatting.

### T007: Implement AppLogger service
- **Status**: [x] Completed
- **Scope**: Create centralized logging wrapper over `package:logger` supporting debug, info, warning, and error levels with environment filtering.
- **Dependencies**: T006
- **Expected Deliverables**:
  - `lib/core/logging/app_logger.dart`
  - `test/core/logging/app_logger_test.dart`
- **Test Requirements**: Validate console output formatting, stack trace preservation, and sensitive data redaction.
- **Acceptance Criteria**: Verbose logging filtered out in production; sensitive payloads redacted across all outputs.

---

## Phase 4: Secure Storage & Application Preferences

### T008: Implement EnvironmentConfig
- **Status**: [x] Completed
- **Scope**: Create compile-time environment configuration (`EnvironmentConfig`) supporting `dev`, `staging`, and `prod`.
- **Dependencies**: T001
- **Expected Deliverables**:
  - `lib/core/network/environment.dart`
- **Test Requirements**: Validate environment detection and base URL defaults.
- **Acceptance Criteria**: Exposes typed environment properties (`apiBaseUrl`, `connectTimeout`, `isProduction`).

### T009: Implement SecureStorageService
- **Status**: [x] Completed
- **Scope**: Create abstraction and implementation over `FlutterSecureStorage` with methods for reading, writing, and clearing tokens.
- **Dependencies**: T002, T003
- **Expected Deliverables**:
  - `lib/core/storage/secure_storage_service.dart`
  - `test/core/storage/secure_storage_test.dart`
- **Test Requirements**: Unit tests with mock secure storage validating CRUD and clear operations.
- **Acceptance Criteria**: Handles null values gracefully and wraps platform errors in `CacheFailure`.

### T010: Implement PreferencesService
- **Status**: [x] Completed
- **Scope**: Create abstraction and implementation over `SharedPreferences` for application settings and flags.
- **Dependencies**: T002, T003
- **Expected Deliverables**:
  - `lib/core/storage/preferences_service.dart`
  - `test/core/storage/preferences_test.dart`
- **Test Requirements**: Unit test checking boolean, string, int, and list storage.
- **Acceptance Criteria**: Provides synchronous reading when backed by initialized instance and async setters.

---

## Phase 5: Networking Infrastructure (Dio & Interceptors)

### T011: Define ApiEndpoints and HTTP configuration constants
- **Status**: [x] Completed
- **Scope**: Establish centralized endpoint constants, timeout durations, and header keys.
- **Dependencies**: T008
- **Expected Deliverables**:
  - `lib/core/network/api_endpoints.dart`
- **Test Requirements**: Verify endpoint URL resolution across environments.
- **Acceptance Criteria**: Endpoints are organized by service module with clean path joining.

### T012: Implement LoggingInterceptor with data masking
- **Status**: [x] Completed
- **Scope**: Build custom Dio interceptor logging request details, query parameters, headers, and responses with data masking.
- **Dependencies**: T006, T007
- **Expected Deliverables**:
  - `lib/core/network/interceptors/logging_interceptor.dart`
  - `test/core/network/interceptors/logging_interceptor_test.dart`
- **Test Requirements**: Intercept mocked requests and verify logs contain masked credentials.
- **Acceptance Criteria**: Headers like `Authorization` and JSON fields like `password` are redacted before output.

### T013: Implement ErrorInterceptor
- **Status**: [x] Completed
- **Scope**: Build custom Dio interceptor that catches `DioException` and translates it into appropriate `AppException`.
- **Dependencies**: T002, T005
- **Expected Deliverables**:
  - `lib/core/network/interceptors/error_interceptor.dart`
  - `test/core/network/interceptors/error_interceptor_test.dart`
- **Test Requirements**: Verify HTTP 400, 401, 403, 404, 500, and socket timeouts are mapped to specific exceptions.
- **Acceptance Criteria**: Exception objects include status codes and error payloads for upstream handlers.

### T014: Implement AuthInterceptor with token refresh queue
- **Status**: [x] Completed
- **Scope**: Build Dio interceptor that injects Bearer token into outgoing requests and handles 401 token refresh queue.
- **Dependencies**: T009, T013
- **Expected Deliverables**:
  - `lib/core/network/interceptors/auth_interceptor.dart`
  - `test/core/network/interceptors/auth_interceptor_test.dart`
- **Test Requirements**: Verify token injection and asynchronous queueing on simulated concurrent 401 responses.
- **Acceptance Criteria**: Avoids redundant simultaneous refresh requests when multiple endpoints return 401.

### T015: Implement ApiClient
- **Status**: [x] Completed
- **Scope**: Configure centralized `Dio` wrapper with `BaseOptions`, interceptors, and typed HTTP methods (GET, POST, PUT, DELETE).
- **Dependencies**: T011, T012, T013, T014
- **Expected Deliverables**:
  - `lib/core/network/api_client.dart`
  - `test/core/network/api_client_test.dart`
- **Test Requirements**: Test mock requests verifying interceptor pipeline and response parsing.
- **Acceptance Criteria**: Returns `Result<T>` or clean response objects; enforces default timeouts.

---

## Phase 6: Local Database Infrastructure (Drift)

### T016: Implement platform database openers
- **Status**: [x] Completed
- **Scope**: Implement native SQLite database connection using `sqlite3_flutter_libs` / `path_provider` and in-memory test opener.
- **Dependencies**: T001
- **Expected Deliverables**:
  - `lib/core/database/connection/connection.dart`
  - `lib/core/database/connection/in_memory_connection.dart`
- **Test Requirements**: Open in-memory Drift connection in unit test.
- **Acceptance Criteria**: Supports WAL mode on device and ephemeral isolation during tests.

### T017: Implement common Drift tables and MigrationManager
- **Status**: [x] Completed
- **Scope**: Define baseline tables (e.g., `SyncMetadataTable`) and migration coordinator handling schema version transitions.
- **Dependencies**: T016
- **Expected Deliverables**:
  - `lib/core/database/tables/sync_metadata_table.dart`
  - `lib/core/database/migrations/migration_manager.dart`
- **Test Requirements**: Test migration callback execution when schema version increases.
- **Acceptance Criteria**: Migration strategy handles `onCreate` and `onUpgrade` safely without unhandled exceptions.

### T018: Implement AppDatabase class and run code generation
- **Status**: [x] Completed
- **Scope**: Create primary `AppDatabase` class extending `_$AppDatabase` with table registrations and run `drift_dev` builder.
- **Dependencies**: T017
- **Expected Deliverables**:
  - `lib/core/database/app_database.dart`
  - Generated `lib/core/database/app_database.g.dart`
- **Test Requirements**: Run `dart run build_runner build --delete-conflicting-outputs`.
- **Acceptance Criteria**: Code generation succeeds cleanly with zero analyzer errors.

### T019: Unit test Drift database operations
- **Status**: [x] Completed
- **Scope**: Write comprehensive test suite for `AppDatabase` using in-memory connection.
- **Dependencies**: T018
- **Expected Deliverables**:
  - `test/core/database/database_test.dart`
- **Test Requirements**: Execute insert, query, update, delete, and migration tests against in-memory instance.
- **Acceptance Criteria**: 100% pass rate; clean disposal without memory leaks.

---

## Phase 7: Declarative Navigation Infrastructure (GoRouter)

### T020: Define RoutePaths and NotFoundScreen
- **Status**: [x] Completed
- **Scope**: Establish static route paths/names and build a user-friendly 404 / Error screen with home navigation action.
- **Dependencies**: T001
- **Expected Deliverables**:
  - `lib/core/router/route_paths.dart`
  - `lib/core/router/screens/not_found_screen.dart`
- **Test Requirements**: Widget test rendering `NotFoundScreen`.
- **Acceptance Criteria**: Screen displays error description and provides button to return to home route.

### T021: Implement RouterListenable for auth/state redirect
- **Status**: [x] Completed
- **Scope**: Create `ChangeNotifier` bridge to allow GoRouter to re-evaluate redirect guards upon authentication state changes.
- **Dependencies**: T020
- **Expected Deliverables**:
  - `lib/core/router/router_listenable.dart`
- **Test Requirements**: Unit test verifying notifications fire when session state updates.
- **Acceptance Criteria**: GoRouter receives notification and triggers route re-evaluation.

### T022: Implement AppRouter and route tests
- **Status**: [x] Completed
- **Scope**: Configure `GoRouter` with initial route, routes list, error builder, and redirect guard logic.
- **Dependencies**: T020, T021
- **Expected Deliverables**:
  - `lib/core/router/app_router.dart`
  - `test/core/router/app_router_test.dart`
- **Test Requirements**: Widget test pushing routes and verifying fallback on unknown URLs.
- **Acceptance Criteria**: Unknown routes display `NotFoundScreen`; redirect guards evaluate properly.

---

## Phase 8: Dependency Injection (GetIt & Injectable)

### T023: Implement Injectable third-party modules
- **Status**: [x] Completed
- **Scope**: Create `@module` classes to provide `Dio`, `AppDatabase`, `FlutterSecureStorage`, and `SharedPreferences` to `GetIt`.
- **Dependencies**: T009, T010, T015, T018
- **Expected Deliverables**:
  - `lib/core/di/modules/network_module.dart`
  - `lib/core/di/modules/storage_module.dart`
  - `lib/core/di/modules/database_module.dart`
- **Test Requirements**: Verify module declarations expose typed providers.
- **Acceptance Criteria**: Follows `@lazySingleton` and `@singleton` lifecycle standards per Constitution Principle III.

### T024: Implement configureDependencies and run Injectable generation
- **Status**: [x] Completed
- **Scope**: Implement `injection.dart` configuring `GetIt` with `@InjectableInit` and execute code generation.
- **Dependencies**: T023
- **Expected Deliverables**:
  - `lib/core/di/injection.dart`
  - Generated `lib/core/di/injection.config.dart`
- **Test Requirements**: Run `dart run build_runner build --delete-conflicting-outputs`.
- **Acceptance Criteria**: DI container compiles without errors or unregistered dependency warnings.

### T025: Unit test Dependency Injection container
- **Status**: [x] Completed
- **Scope**: Test resolution of all core services across development and testing environments.
- **Dependencies**: T024
- **Expected Deliverables**:
  - `test/core/di/injection_test.dart`
- **Test Requirements**: Resolve `ApiClient`, `AppDatabase`, `SecureStorageService`, and `PreferencesService`.
- **Acceptance Criteria**: All singletons resolve to identical instances; container resets cleanly on `reset()`.

---

## Phase 9: Shared Testing Harness & Quality Verification

### T026: Build shared testing utilities and mocks
- **Status**: [x] Completed
- **Scope**: Create reusable `MockDioAdapter`, `MockServices`, and test DI helper for feature module tests.
- **Dependencies**: T015, T018, T025
- **Expected Deliverables**:
  - `test/core/test_helpers/mock_dio_adapter.dart`
  - `test/core/test_helpers/mock_services.dart`
  - `test/core/test_helpers/test_injection.dart`
- **Test Requirements**: Run sample test consuming shared test helpers.
- **Acceptance Criteria**: Any subsequent feature test can import these helpers to mock network and storage cleanly.

### T027: Full static analysis, formatting, and test suite execution
- **Status**: [x] Completed
- **Scope**: Run complete test suite, formatting, and static analysis across the entire project.
- **Dependencies**: All preceding tasks (T001-T026)
- **Expected Deliverables**:
  - Clean test execution report and analysis logs.
- **Test Requirements**:
  - `dart format --output=none --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
- **Acceptance Criteria**: 0 warnings, 0 errors, 100% passing tests.

---

## Execution Constraints & Safeguards

1. **Review Gate**: Implementation MUST NOT begin until the user reviews this task list and approves execution.
2. **Sequential Implementation**: Implement tasks sequentially following the phase order (Phase 1 ➔ Phase 9).
3. **Validation After Each Phase**:
   - Run tests for the modified domain.
   - Run Dart formatter (`dart format`).
   - Run static analysis (`flutter analyze`).
   - Report progress and verify compliance with Constitution v2.0.0.
