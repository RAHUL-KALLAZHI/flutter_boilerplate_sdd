# Feature Specification: Project Initialization & Architectural Baseline

**Feature Branch**: `001-project-setup`
**Created**: 2026-11-19
**Status**: Implemented / Approved

## Architectural Decisions Established in Feature 001

1. **Architecture Style**: Feature-First Clean Architecture (`lib/core/` and `lib/features/<name>/{domain,data,presentation}`).
2. **State Management**: BLoC / Cubit pattern (`flutter_bloc`) with immutable states and events.
3. **Dependency Injection**: Service locator via `get_it` with code generation using `injectable`.
4. **Networking**: `dio` with custom interceptors for authentication, logging, and error handling.
5. **Local Persistence**: `drift` (type-safe SQLite) for structured relational data, `flutter_secure_storage` for credentials/tokens, and `shared_preferences` for non-sensitive settings.
6. **Navigation**: Declarative routing via `go_router`.
7. **Error Handling**: Explicit functional `Failure` abstractions in domain layer preventing leaky exceptions.
8. **Testing Rigor**: Unit tests for domain & data, widget tests for presentation, mocktail/mockito for test isolation.
