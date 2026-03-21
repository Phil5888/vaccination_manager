# Requirements Traceability Matrix

This matrix links requirements to implementation areas and tests.
Update this file whenever requirements or coverage change.

| Requirement ID | Requirement Summary                                  | Source File                           | Planned/Current Implementation Areas                                                              | Planned/Current Test Coverage    | Status  |
| -------------- | ---------------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------- | -------------------------------- | ------- |
| FR-001         | Creation and management of patient profiles          | docs/requirements/product-overview.md | lib/presentation/screens, lib/presentation/viewmodels, lib/data/repositories, lib/domain/usecases | test/widget, test/unit           | Planned |
| FR-002         | Recording and viewing vaccination events             | docs/requirements/product-overview.md | lib/presentation/screens, lib/data/repositories, lib/domain/entities                              | test/widget, test/unit           | Planned |
| FR-003         | Reminder workflows for upcoming/overdue vaccinations | docs/requirements/product-overview.md | lib/presentation/screens, lib/presentation/viewmodels, lib/domain/usecases                        | test/unit, test/widget           | Planned |
| NFR-001        | Responsive UI behavior for common actions            | docs/requirements/product-overview.md | lib/presentation/widgets, lib/presentation/screens                                                | test/widget, manual verification | Planned |
| NFR-002        | Localization support across configured locales       | docs/requirements/product-overview.md | lib/l10n, lib/presentation                                                                        | test/widget, l10n validation     | Planned |
| AC-001         | Create patient profile and retrieve it later         | docs/requirements/product-overview.md | Linked to FR-001 flow                                                                             | test/widget, test/unit           | Planned |
| AC-002         | Add vaccination event and view in history            | docs/requirements/product-overview.md | Linked to FR-002 flow                                                                             | test/widget, test/unit           | Planned |
| AC-003         | Reminder views show upcoming/overdue states          | docs/requirements/product-overview.md | Linked to FR-003 flow                                                                             | test/widget, test/unit           | Planned |

## Maintenance Notes

- Keep requirement IDs synchronized with source requirement files.
- Prefer updating existing rows over creating duplicates.
- Use status values like Planned, In Progress, Implemented, Verified.
