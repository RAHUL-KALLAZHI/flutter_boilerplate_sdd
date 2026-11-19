# flutter_boilerplate_sdd

A Flutter boilerplate built for **Spec-Driven Development (SDD)** with [GitHub Spec Kit](https://github.com/github/spec-kit).

## 🚀 Spec-Driven Development Workflow

This project is configured with GitHub Spec Kit (`specify`), establishing a specification-first methodology for AI coding agents and human developers.

```
       ┌──────────────────┐
       │ /speckit-specify │  ───▶ Create spec in specs/<feature>/spec.md
       └─────────┬────────┘
                 │
                 ▼
       ┌──────────────────┐
       │ /speckit-clarify │  ───▶ (Optional) De-risk ambiguities
       └─────────┬────────┘
                 │
                 ▼
       ┌──────────────────┐
       │  /speckit-plan   │  ───▶ Technical architecture & plan.md
       └─────────┬────────┘
                 │
                 ▼
       ┌──────────────────┐
       │  /speckit-tasks  │  ───▶ Granular tasks in tasks.md
       └─────────┬────────┘
                 │
                 ▼
       ┌──────────────────┐
       │/speckit-implement│  ───▶ Iterative code & test execution
       └─────────┬────────┘
                 │
                 ▼
       ┌──────────────────┐
       │/speckit-converge │  ───▶ Verify & append remaining delta
       └──────────────────┘
```

### Core Commands & Skills

| Command / Skill | Purpose |
| :--- | :--- |
| `/speckit-constitution` | Establish or amend project architectural rules & quality standards |
| `/speckit-specify <description>` | Generate a structured functional specification |
| `/speckit-clarify` | Interactively surface edge cases and resolve ambiguities |
| `/speckit-plan` | Architect technical implementation, file layouts, and dependencies |
| `/speckit-checklist` | Generate quality checklists to validate requirements |
| `/speckit-tasks` | Decompose the technical plan into sequential actionable checklist tasks |
| `/speckit-analyze` | Audit consistency and alignment between spec, plan, and tasks |
| `/speckit-implement` | Execute implementation of tasks sequentially with testing |
| `/speckit-converge` | Compare current codebase to specs and capture remaining work |
| `/speckit-taskstoissues` | Export task items to issue trackers |

---

## 📁 Project Structure

```
├── .agents/skills/          # Spec Kit skills configured for Antigravity
├── .specify/                # Spec Kit core configuration, templates, scripts & memory
│   ├── memory/              # Project constitution (constitution.md)
│   ├── scripts/             # Shell automation scripts (feature creation, planning, etc.)
│   ├── templates/           # Markdown templates for specs, plans, tasks, checklists
│   └── workflows/           # Spec Kit automation workflows
├── specs/                   # Feature specifications directory
├── lib/                     # Application source code
└── test/                    # Unit & widget tests
```

---

## 🛠️ CLI Usage

If you have `specify-cli` installed globally or via `uv`:

```bash
# Check Spec Kit configuration
specify check

# Check active integrations
specify integration status

# Create a new feature spec branch and directory
.specify/scripts/bash/create-new-feature.sh "Add user authentication" --short-name "user-auth"
```

---

## 📱 Getting Started with Flutter

This project uses Flutter with FVM:
```bash
# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run test suite
flutter test
```
