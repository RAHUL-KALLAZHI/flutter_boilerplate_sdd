# Feature Specification: 002-core-shared-infrastructure

**Feature Branch**: `002-core-shared-infrastructure`  
**Created**: 2026-11-19  
**Status**: Ready for Review  
**Input**: LifeHub Core Shared Infrastructure requirements  

## Summary

Prepare and implement the shared, reusable infrastructure required by all subsequent LifeHub features. This feature establishes cross-cutting foundations in `lib/core/` across eight critical domains: Networking (Dio), Dependency Injection (GetIt/Injectable), Local Database (Drift), Secure Storage & Preferences, Declarative Navigation (GoRouter), Common Error Handling, Logging with Data Masking, and Shared Testing Utilities.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Unified Dependency Injection & Environment Configuration (Priority: P1) 🎯 MVP

As a developer building LifeHub feature modules, I need a centralized service locator and code-generated dependency registration mechanism so that I can inject and resolve singleton and factory services predictably across development, staging, and production environments.

**Why this priority**: Dependency injection is the bedrock prerequisite for registering and resolving all subsequent services (database, networking, storage, navigation).

**Independent Test**: Register mock, singleton, and factory dependencies using GetIt and Injectable annotations, initialize the DI container, and verify instances resolve properly with environment-specific configurations.

**Acceptance Scenarios**:
1. **Given** an environment configuration (`dev`, `staging`, `prod`), **When** `configureDependencies(environment)` is called at startup, **Then** all annotated services are registered in `GetIt` with the correct environment bindings.
2. **Given** a service registered as `@lazySingleton`, **When** resolved multiple times, **Then** the exact same instance is returned on each resolution.
3. **Given** a test environment, **When** `resetDependencies()` is called, **Then** the container is cleared and ready for mock registrations without cross-test state leakage.

---

### User Story 2 - Resilient Networking Client with Interceptors (Priority: P1)

As a feature developer, I need a standardized Dio HTTP client equipped with request, response, and error interceptors so that network communication is consistent, authenticated, resilient, and automatically mapped to domain-level errors.

**Why this priority**: All remote data sources across LifeHub depend on reliable, uniform HTTP communication.

**Independent Test**: Execute simulated HTTP requests against a mocked adapter and verify timeout configuration, header injection (Authorization token), request/response logging, and HTTP error transformation into `ServerFailure`.

**Acceptance Scenarios**:
1. **Given** an outgoing HTTP request, **When** an auth token exists in secure storage, **Then** the client attaches `Authorization: Bearer <token>` automatically via request interceptor.
2. **Given** an endpoint responding with HTTP 401 Unauthorized, **When** the error interceptor intercepts it, **Then** the error is mapped to an `UnauthorizedFailure` and token refresh/session expiration handling is triggered.
3. **Given** network disconnection or socket timeout, **When** a request is attempted, **Then** the client returns a `NetworkFailure` or `TimeoutFailure` with descriptive, user-safe messages.

---

### User Story 3 - Common Error Abstractions & Result Handling (Priority: P1)

As a developer implementing clean architecture layers, I need standardized `AppException` and `Failure` hierarchies with a functional `Result` (or `Either`) pattern so that errors from data sources never leak raw technical exceptions into domain or presentation layers.

**Why this priority**: Enforces Constitution Principle IV and Clean Architecture separation, providing predictable error representations to UI BLoCs.

**Independent Test**: Instantiate various data-source exceptions and pass them through error mappers, verifying that the output is always a strongly typed `Failure` with localized user-safe messaging.

**Acceptance Scenarios**:
1. **Given** a raw `DioException` or `SqliteException`, **When** passed to the error mapper, **Then** it transforms into a domain `Failure` (`ServerFailure`, `CacheFailure`, etc.) without loss of internal debugging context.
2. **Given** a repository method returning `Result<T>`, **When** an operation succeeds, **Then** it returns `Result.success(data)`; **When** it fails, **Then** it returns `Result.failure(failure)` without throwing uncaught exceptions.

---

### User Story 4 - Secure Storage & Application Preferences (Priority: P1)

As a feature module, I need abstracted secure storage for sensitive credentials and shared preferences for non-sensitive flags so that sensitive user data is encrypted at rest on iOS/Android while general settings remain lightweight.

**Why this priority**: Required by authentication, user session management, theme preferences, and onboarding flags.

**Independent Test**: Read and write sensitive tokens and non-sensitive preference keys using the storage abstractions, validating encryption and platform compatibility.

**Acceptance Scenarios**:
1. **Given** an authentication token, **When** stored via `SecureStorageService`, **Then** it is securely persisted in Android EncryptedSharedPreferences / iOS Keychain.
2. **Given** a non-sensitive setting (e.g., theme mode), **When** written to `PreferencesService`, **Then** it persists across application restarts.
3. **Given** a user logout event, **When** `clearSecureStorage()` is called, **Then** all credentials are wiped while preserving user device preferences.

---

### User Story 5 - Structured Logging with Sensitive Data Masking (Priority: P1)

As a developer diagnosing issues, I need centralized, leveled logging that automatically masks sensitive information (passwords, tokens, PII) so that logs provide diagnostic value in development without violating user privacy or compliance in production.

**Why this priority**: Required for debugging networking, database queries, and lifecycle events while safeguarding sensitive data per Constitution Principle VII.

**Independent Test**: Log messages and payloads containing `"password"`, `"token"`, `"authorization"`, and credit card / PII patterns, verifying that sensitive strings are redacted with `***MASKED***`.

**Acceptance Scenarios**:
1. **Given** an HTTP request with an `Authorization: Bearer xyz123` header, **When** logged, **Then** the header value appears as `Bearer ***MASKED***`.
2. **Given** a production environment build, **When** verbose/debug logs are triggered, **Then** they are filtered out and only warnings and errors are output.

---

### User Story 6 - Local Relational Database & Migration Infrastructure (Priority: P2)

As a feature requiring offline persistence, I need an initialized Drift SQLite database with clean abstractions, connection handling, and versioned migration support so that features can persist structured relational data safely.

**Why this priority**: Offline capabilities and local caching across LifeHub require a robust, schema-migrated local database foundation.

**Independent Test**: Initialize an in-memory Drift database instance, run schema migrations, perform CRUD queries through a DAO abstraction, and verify transaction integrity.

**Acceptance Scenarios**:
1. **Given** application launch, **When** the database service initializes, **Then** the native SQLite file is opened with WAL (Write-Ahead Logging) mode and foreign keys enabled.
2. **Given** a schema upgrade from version N to N+1, **When** the database opens, **Then** migration callbacks execute in sequence without data corruption.
3. **Given** domain layers needing database access, **When** interacting with persistence, **Then** they interact solely via abstract repository interfaces without referencing Drift table classes directly.

---

### User Story 7 - Declarative Navigation & Routing (Priority: P2)

As a user navigating LifeHub, I need a declarative GoRouter routing system that supports deep linking, route guards (authentication redirects), and customizable error pages so that transitions are type-safe and consistent.

**Why this priority**: Central routing framework needed before any UI screens or feature flows can be connected.

**Independent Test**: Push routes, evaluate redirect guards based on auth state, trigger an invalid route, and verify navigation to the standardized `NotFoundScreen`.

**Acceptance Scenarios**:
1. **Given** navigation to a route requiring authentication, **When** the user is unauthenticated, **Then** GoRouter redirects to `/login`.
2. **Given** an unknown URI, **When** navigation is attempted, **Then** GoRouter displays the centralized `ErrorScreen` with recovery actions.
3. **Given** modular feature packages, **When** registering routes, **Then** features can contribute child route lists to the core router configuration cleanly.

---

### User Story 8 - Shared Testing Infrastructure & Harness (Priority: P2)

As a developer writing automated tests for any feature, I need shared test doubles, mock factories, in-memory database helpers, and mock Dio adapters so that testing is fast, deterministic, and isolated.

**Why this priority**: Fulfills Constitution Principle VIII by providing reusable testing scaffolding for all subsequent features.

**Independent Test**: Write a sample test verifying DI replacement with mocks, an in-memory Drift test database, and simulated Dio responses without actual network calls.

**Acceptance Scenarios**:
1. **Given** a unit test requiring database operations, **When** requesting a test database, **Then** an ephemeral in-memory Drift connection is provided.
2. **Given** an HTTP test, **When** sending requests, **Then** a `MockDioAdapter` intercepts requests and returns predefined responses or errors synchronously.

---

## Edge Cases

- **Platform Incompatibilities**: Android KeyStore or iOS Keychain access lockups during background execution or device reboot before first unlock.
- **Corrupted Local DB**: Handling SQLite disk I/O failure or corrupted database files gracefully by triggering database rebuild / repair routines.
- **Concurrent Token Refresh**: Multiple asynchronous API requests encountering 401 simultaneously must queue behind a single refresh request rather than triggering redundant token refresh calls.
- **Network Flapping**: Rapid switching between WiFi and Cellular during active HTTP requests handled with clean timeout recovery.
- **Deep Link Malformation**: Malformed query parameters or unparseable deep link URIs safely routed to the error route without crashing the app.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a centralized `Dio` HTTP client with custom interceptors for Auth, Logging (masked), and Error Mapping.
- **FR-002**: System MUST configure `GetIt` and `Injectable` supporting `dev`, `staging`, `prod`, and `test` environments.
- **FR-003**: System MUST provide an initialized `Drift` database with connection pooling, platform-specific database openers, and migration callbacks.
- **FR-004**: System MUST provide a `SecureStorageService` (wrapping `FlutterSecureStorage`) and `PreferencesService` (wrapping `SharedPreferences`).
- **FR-005**: System MUST configure `GoRouter` with centralized routes, redirect guard hooks, and a custom error/404 screen.
- **FR-006**: System MUST define unified `AppException` and `Failure` hierarchies along with a `Result<T>` wrapper for safe functional error propagation.
- **FR-007**: System MUST provide a `LoggerService` that redacts passwords, tokens, and PII, filtering verbose logs in production.
- **FR-008**: System MUST provide shared test helpers (in-memory Drift database builder, mock Dio interceptors, and DI reset utilities).

### Key Entities & Abstractions

- **`EnvironmentConfig`**: Represents active environment (`dev`, `staging`, `prod`) with base URLs and API configuration.
- **`AppDatabase`**: Drift database instance handling tables and migrations.
- **`SecureStorage` & `AppPreferences`**: Key-value persistence abstractions.
- **`Failure` & `AppException`**: Domain and infrastructure error definitions.
- **`Result<T>`**: Success/Failure container for business operations.
- **`AppRouter`**: GoRouter configuration and route registry.
- **`AppLogger`**: Unified logging interface.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the eight infrastructure areas implemented and verified in `lib/core/`.
- **SC-002**: Zero business features coupled to raw third-party infrastructure (Dio, Drift, or Storage directly imported into domain code).
- **SC-003**: 100% pass rate on infrastructure unit and integration tests (`flutter test`).
- **SC-004**: Zero static analysis errors or warnings (`flutter analyze`).
- **SC-005**: PII and authentication tokens are masked in 100% of tested log statements.
- **SC-006**: All subsequent LifeHub features can consume core infrastructure without re-implementing networking, database, DI, or logging.

---

## Architectural Decisions & Clarifications (via /speckit-clarify)

1. **Environment Configuration**: Implemented using compile-time constants (`--dart-define` / `--dart-define-from-file`) via an `EnvironmentConfig` class (`dev`, `staging`, `prod`) to avoid bundling vulnerable plain-text `.env` assets.
2. **Functional Error Handling**: Implemented using a native Dart 3 sealed class `Result<T>` (`Success<T>` and `FailureResult<T>`) leveraging pattern matching, avoiding legacy third-party monad dependencies like `dartz` or `fpdart`.
3. **Drift SQLite Setup**: Mobile and desktop platforms will use `drift` with `sqlite3_flutter_libs` and `path_provider`. Test harness will use `DatabaseConnection.inMemory()` for zero-disk, ultra-fast test isolation.
4. **Token Refresh Concurrency**: An async lock/queue mechanism in Dio interceptors ensures that when multiple requests hit 401 simultaneously, only one refresh call executes while others await the new token.
5. **GoRouter Refresh & Guards**: Configured with an `AppRouter` class exposing `GoRouter`, using a `RouterListenable` hook to trigger automatic redirects when session state transitions occur.

---

## Assumptions

- Flutter SDK version >= 3.44.5 (Dart >= 3.4.4 < 4.0.0) is configured via FVM.
- Dependencies (`dio`, `get_it`, `injectable`, `drift`, `flutter_secure_storage`, `shared_preferences`, `go_router`, `flutter_bloc`, `logger`) will be added to `pubspec.yaml` with compatible versions.
- All code resides in `lib/core/` and `test/core/` to maintain clean feature boundaries.
