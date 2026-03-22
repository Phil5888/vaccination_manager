# Copilot Instructions — Vaccination Manager

## Commands

All Flutter commands must be run from `src/` (the Flutter project root containing `pubspec.yaml`):

```bash
cd src

flutter test                                   # run all tests
flutter test test/path/to/test_file.dart       # run a single test file
flutter analyze                                # lint
flutter run                                    # run the app
```

No code generation step is needed — `riverpod_generator` is listed as a dev dependency but no `@riverpod` annotations are used; all providers are written manually.

## Architecture

The project follows Clean Architecture with three layers inside `lib/`:

```
domain/       # Pure Dart — entities, repository interfaces, use cases
data/         # Flutter/sqflite — models (DB DTOs), repository implementations
presentation/ # Flutter — viewmodels, providers, screens, widgets, navigation
core/         # Shared infrastructure — AppDatabase singleton, constants, utils
l10n/         # Generated localization files (en + de)
```

**Data flow:** Screens consume Riverpod providers → providers expose `AsyncNotifier` viewmodels → viewmodels call use cases → use cases call repository interfaces → implementations hit SQLite via `AppDatabase.instance`.

**Key derived concept:** `VaccinationSeriesEntity` is not stored in the database. It is computed in `VaccinationViewModel._loadState` by grouping `VaccinationEntryEntity` records (from SQLite) by their lowercased `name`. The DB stores individual shots; the series grouping is in-memory only.

**Startup gate:** `AppStartupGate` (in `screens/startup/`) checks whether any users exist and redirects to the welcome flow if not.

**Navigation:** `AppRouter.generateRoute` uses `Navigator` with named routes defined in `core/constants/routes.dart`. Route arguments are passed via `RouteSettings.arguments` and cast at the destination.

## Key Conventions

### Providers

Each feature's providers are split into two files:
- `{feature}_dependency_providers.dart` — repository provider + use case providers (plain `Provider<T>`)
- `{feature}_providers.dart` — the `AsyncNotifierProvider` for the viewmodel

Viewmodels extend `AsyncNotifier<State>`. Use cases are thin callable classes (`call` operator).

### Data models

`data/models/*.dart` each implement four methods:
- `fromMap(Map<String, dynamic>)` — deserialize from SQLite row
- `toMap()` — serialize to SQLite row
- `fromEntity(Entity)` — convert from domain entity
- `toEntity()` — convert to domain entity

### Testing

Tests use `ProviderContainer` with provider `overrides` — never the real database. Fake repositories live in `test/helpers/fakes/`. Widget tests use `ProviderScope` with the same override pattern.

### Localization

All user-visible strings go through `AppLocalizations` (generated from ARB files in `lib/l10n/`). Access via `AppLocalizations.of(context)` or `l10n` helper in `core/utils/localization_utils.dart`. When adding strings, update both `app_en.arb` and `app_de.arb`.

## Requirements-Aware Workflow

When useful for implementation, review, architecture change, localization update, or test work:

1. Check applicable requirement file(s) in `docs/requirements/`.
2. Map work to requirement IDs and acceptance criteria when this adds clarity.
3. If requirements are missing or unclear, optionally route through the Requirements Engineer agent (`.github/agents/requirements_engineer.agent.md`).

**Execution rules:**
- Requirements references are recommended, not mandatory, for every task.
- Keep implementation and review outputs traceable to requirement IDs when practical.
- If requested behavior conflicts with existing requirements, call out the conflict and request a requirement update.
- When requirements are updated, also update `docs/requirements/traceability-matrix.md`.

**Reporting:** For implementation, review, testing, localization, and architecture tasks, include when relevant: requirement source file(s), requirement ID(s), acceptance criteria covered, and any gaps or ambiguities.
