<!--
Sync Impact Report:
- Version change: 1.0.0 -> 2.0.0 (Major amendment for LifeHub architecture)
- Ratification / Last Amended: 2026-11-19
- Standardized State Management on flutter_bloc / Cubit
- Standardized Dependency Injection on GetIt + Injectable
- Standardized Local Persistence on Drift (relational) + FlutterSecureStorage + SharedPreferences
- Standardized Networking on Dio + Interceptors + Unified Error Mapping
- Standardized Navigation on GoRouter
- Codified strict logging, privacy/masking, and testing gates
-->

# LifeHub Constitution

## Core Principles

### I. Spec-First & Feature-First Clean Architecture
Every feature or shared subsystem must be anchored by a specification in `specs/<feature-number>-<feature-name>/`. Implementation never precedes approved requirements (`spec.md`), technical architecture (`plan.md`), and atomic tasks (`tasks.md`).
- Code must reside in `lib/core/` for cross-cutting infrastructure or `lib/features/<feature_name>/` for business capabilities.
- Strict Clean Architecture layer separation is non-negotiable:
  - **Domain (`domain/`)**: Pure Dart entities, use cases, and repository interfaces. No Flutter UI, network, or database dependencies.
  - **Data (`data/`)**: Concrete data sources, DTO models (JSON/Drift), and repository implementations.
  - **Presentation (`presentation/`)**: BLoC/Cubit controllers, UI widgets, and screens. UI widgets are dumb and reactive.

### II. State Management with BLoC / Cubit
- All complex asynchronous state flows and business events must be managed using BLoC or Cubit (`flutter_bloc`).
- Presentation widgets must never mutate state or call repositories directly; they dispatch events or trigger Cubit methods.
- States and events must be immutable (using value equality).

### III. Dependency Injection & Service Lifecycle (GetIt + Injectable)
- All services, repositories, data sources, and BLoCs must be registered and resolved through `GetIt` with code-generation support via `injectable`.
- Follow strict lifecycle annotations (`@lazySingleton`, `@singleton`, `@injectable`).
- Infrastructure code must expose test-friendly injection points (support for mock registration in testing environments).

### IV. Centralized Networking & Error Handling (Dio)
- All HTTP communication must pass through a centralized, configured `Dio` client.
- Required interceptors: Logging (with sensitive data masking), Authentication/Token refresh, and Unified Error Interceptor.
- Errors must be mapped at the data boundary into domain-level `Failure` objects (e.g., `ServerFailure`, `NetworkFailure`, `UnauthorizedFailure`) rather than leaking raw exceptions to the UI.

### V. Local Storage, Abstraction & Data Privacy (Drift & Secure Storage)
- Structured relational persistence must use `Drift` with explicit migration infrastructure and table definitions.
- Sensitive credentials (tokens, keys, secrets) must use `flutter_secure_storage`. General app flags must use `shared_preferences`.
- Drift database access must always be abstracted behind data sources and repository interfaces. Domain layers must never directly import Drift tables or query builders.

### VI. Declarative Routing & Error Handling (GoRouter)
- Navigation must be implemented via `GoRouter` with centralized route definitions and route-level error handling.
- Feature routes must be modularized and extendable without modifying the core navigation router internals unnecessarily.

### VII. Observability, Logging & Sensitive Data Masking
- Centralized logging must distinguish between development (verbose) and production (filtered/error-only).
- Sensitive user information (passwords, tokens, PII) must be masked in log statements and HTTP request/response interceptors.

### VIII. Non-Negotiable Testing & Quality Gates
- Every domain use case and repository implementation must have unit tests.
- Infrastructure components (networking interceptors, database migrations, storage abstractions) must have dedicated test suites.
- Code must pass `dart analyze` with zero warnings and zero errors, and conform to `dart format`.

## Governance

This Constitution represents the non-negotiable architectural contract for LifeHub. All pull requests, code reviews, and automated agent workflows must verify compliance against these principles. Any amendments to this constitution require documentation, justification, and version incrementing following semantic versioning.

**Version**: 2.0.0 | **Ratified**: 2026-11-19 | **Last Amended**: 2026-11-19
