# Test Cases — Index

This folder contains structured test case documentation for the Vaccination Manager app.
Cases are organised by feature area. Each file maps test scenarios to requirement IDs,
describes preconditions/steps, and cross-references the automated test file and test name.

> **Previous location:** `docs/test_use_cases.md` contains the original USER-SWITCH cases.
> Those cases have been migrated here. `test_use_cases.md` is kept for historical reference
> but `docs/test_cases/` is the canonical location going forward.

---

## Files

| File | Feature area | Cases |
|---|---|---|
| [vaccination_records.md](vaccination_records.md) | Add / edit / delete vaccination records, multi-shot series, record next shot | QA-VAX-REC-* |
| [vaccination_reminders.md](vaccination_reminders.md) | Reminder computation, schedule filtering, lead-time settings | QA-VAX-REM-* |
| [user_profiles.md](user_profiles.md) | Profile creation, active user switching, per-user data isolation | QA-VAX-USR-* |
| [widget_and_screen_tests.md](widget_and_screen_tests.md) | Widget rendering, screen integration, navigation flows | QA-NAV-*, QA-DASH-*, QA-REC-SCR-*, QA-SCH-SCR-*, QA-ADD-SCR-*, QA-PROF-SCR-*, QA-CARD-* |

---

## QA ID Namespace

| Prefix | Feature |
|---|---|
| `QA-VAX-REC-ADD-*` | Add vaccination (single-shot) |
| `QA-VAX-REC-MULTI-*` | Add vaccination (multi-shot) |
| `QA-VAX-REC-EDIT-*` | Edit vaccination series |
| `QA-VAX-REC-DEL-*` | Delete vaccination series |
| `QA-VAX-REC-RNXT-*` | Record next shot |
| `QA-VAX-REM-*` | Reminder computation |
| `QA-VAX-USR-*` | User profiles / switching |
| `QA-NAV-*` | Shell navigation (tabs, FAB, routing) |
| `QA-DASH-*` | Dashboard screen rendering |
| `QA-REC-SCR-*` | Records screen rendering |
| `QA-SCH-SCR-*` | Schedule screen rendering |
| `QA-ADD-SCR-*` | Add vaccination screen rendering |
| `QA-PROF-SCR-*` | Profile screen rendering |
| `QA-CARD-*` | VaccinationSeriesCard widget |
