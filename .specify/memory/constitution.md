<!--
Sync Impact Report:
- Version change: Initial Draft -> 1.0.0
- Ratification: 2026-11-19
- Defined Core Principles for Flutter Spec-Driven Development (SDD)
- Added Architectural Constraints & Code Quality Gates
- Configured Development Workflow & Governance rules
-->

# Flutter Boilerplate SDD Constitution

## Core Principles

### I. Spec-First & Feature Isolation
Every new capability, substantial refactoring, or bugfix must be anchored by a specification in `specs/<feature-number>-<feature-name>/`. Implementation never precedes approved requirements (`spec.md`), technical architecture (`plan.md`), and atomic tasks (`tasks.md`). Features must remain decoupled, modular, and self-contained.

### II. Clean Layered Architecture
Code must strictly adhere to the layered separation of concerns:
- **Presentation Layer (`lib/features/.../presentation` or `lib/ui`)**: Flutter widgets and page layouts. Widgets must be dumb, reactive, and free of direct API, database, or heavy domain logic.
- **Application / State Layer (`lib/features/.../state` or `logic`)**: State management and orchestration. Coordinates presentation with business logic.
- **Domain Layer (`lib/features/.../domain`)**: Entities, value objects, and repository interfaces. Pure Dart with no Flutter UI dependencies.
- **Data Layer (`lib/features/.../data`)**: Concrete data sources, HTTP clients, local storage, and DTOs/serialization.

### III. Test-First & Non-Negotiable Quality Gates
Quality is enforced before code merges:
- Business logic, repositories, and state managers must have unit test coverage using `package:test` or `package:flutter_test`.
- Reusable UI components and critical screens must have widget tests verifying rendering, user interactions, and error states.
- Code must pass `dart analyze` with zero warnings and zero errors.

### IV. Type Safety, Null Safety & API Contracts
- Sound null safety is strictly enforced across the codebase; avoiding unsafe force-unwraps (`!`) unless proven invariant by preceding assertions.
- External data models (JSON, network, persistence) must implement validated serialization (`fromJson` / `toJson`).

### V. Cross-Platform Responsiveness & Accessibility (a11y)
- Layouts must adapt gracefully across screen dimensions using responsive patterns (`LayoutBuilder`, flexible layouts, or breakpoints).
- Visual elements, buttons, inputs, and touch targets must meet accessibility standards (sufficient contrast, semantic labels, minimum tap target sizing).

## Quality Gates & Tooling

1. **Static Analysis**: `flutter analyze` or `dart analyze` must run cleanly without warnings or errors.
2. **Formatting**: Code must strictly conform to `dart format`.
3. **Execution Verification**: All automated tests (`flutter test`) must pass before feature completion.
4. **Git Branching**: Features should be developed in dedicated branches matching `specs/<feature-id>-<short-name>`.

## Development Workflow

1. **Specify (`/speckit-specify`)**: Define natural language requirements, user stories, acceptance criteria, and constraints.
2. **Clarify & Checklist (`/speckit-clarify`, `/speckit-checklist`)**: De-risk ambiguities and generate quality checklists.
3. **Plan (`/speckit-plan`)**: Map out architectural changes, data contracts, dependencies, and file layout.
4. **Tasks (`/speckit-tasks`)**: Break down implementation into granular, sequential checklist tasks.
5. **Implement & Converge (`/speckit-implement`, `/speckit-converge`)**: Execute tasks iteratively, write tests, verify regressions, and reconcile remaining delta work.

## Governance

This Constitution represents the non-negotiable architectural contract for this project. All pull requests, code reviews, and automated agent workflows must verify compliance against these principles. Any amendments to this constitution require documentation, justification, and version incrementing following semantic versioning.

**Version**: 1.0.0 | **Ratified**: 2026-11-19 | **Last Amended**: 2026-11-19
