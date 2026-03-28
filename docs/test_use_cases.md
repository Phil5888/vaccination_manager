# Test Use Cases

> **⚠️ Deprecated location.**
> New and updated test case documentation lives in [`docs/test_cases/`](test_cases/README.md).
> The user-switch cases below have been migrated to [`docs/test_cases/user_profiles.md`](test_cases/user_profiles.md)
> with updated IDs (QA-VAX-USR-001..005). This file is kept for historical reference only.

This document captures behavior-driven QA use cases in a natural step and expected-result format.

## QA-VAX-REG-USER-SWITCH-001

Goal: Verify that switching from user A to user B while vaccinations are in use does not crash and updates data to user B records only.

Requirement mapping:

- Source files: docs/requirements/product-overview.md, docs/requirements/traceability-matrix.md
- IDs: FR-002, FR-004, AC-006, AC-009, NFR-001

Preconditions:

- The app has at least two user profiles.
- User A is active at the start.
- User A and user B each have distinct vaccination entries.

Test data:

- User A: Alice, vaccination series COVID-19
- User B: Bob, vaccination series FSME

Steps and expected results:

| Step | Action                                                | Expected                                                      |
| ---- | ----------------------------------------------------- | ------------------------------------------------------------- |
| 1    | Open vaccinations while active user is A.             | Vaccinations load without error and show user A records only. |
| 2    | Switch active user from A to B.                       | User switch succeeds and app remains responsive.              |
| 3    | Return to or refresh vaccinations state after switch. | No exception occurs during rebuild/load.                      |
| 4    | Inspect vaccination data.                             | Only user B records are shown; user A records are not shown.  |

Automation target:

- Test file: src/test/presentation/viewmodels/vaccination_viewmodel_test.dart
- Test name: switches from user with vaccinations to user with vaccinations without reinitialization crash
- Test file: src/test/presentation/screens/vaccinations/vaccinations_screen_test.dart
- Test name: while vaccinations are visible, switching active user updates records without crash

## QA-VAX-REG-USER-SWITCH-002

Goal: Verify that switching from a user with vaccinations to a user without vaccinations does not crash and transitions to the empty-state view.

Requirement mapping:

- Source files: docs/requirements/product-overview.md, docs/requirements/traceability-matrix.md
- IDs: FR-002, FR-004, AC-006, AC-009, NFR-001

Preconditions:

- Two users exist.
- User A has vaccination records.
- User B has no vaccination records.

Steps and expected results:

| Step | Action                                     | Expected                                                                              |
| ---- | ------------------------------------------ | ------------------------------------------------------------------------------------- |
| 1    | Open vaccinations while active user is A.  | Vaccinations list for user A is shown.                                                |
| 2    | Switch active user to B.                   | No exception occurs while switching.                                                  |
| 3    | Return to or refresh vaccinations content. | Empty-state content is shown for user B, and user A vaccination series are not shown. |

Automation target:

- Test file: src/test/presentation/viewmodels/vaccination_viewmodel_test.dart
- Test name: switches from user with vaccinations to user without vaccinations without reinitialization crash
- Test file: src/test/presentation/screens/vaccinations/vaccinations_screen_test.dart
- Test name: while vaccinations are visible, switching active user to empty records updates empty state without crash

## QA-VAX-REG-USER-SWITCH-003

Goal: Verify that switching from a user without vaccinations to a user with vaccinations does not crash and displays the new user's vaccination records.

Requirement mapping:

- Source files: docs/requirements/product-overview.md, docs/requirements/traceability-matrix.md
- IDs: FR-002, FR-004, AC-006, AC-009, NFR-001

Preconditions:

- Two users exist.
- User A has no vaccination records.
- User B has vaccination records.

Steps and expected results:

| Step | Action                                     | Expected                                                                    |
| ---- | ------------------------------------------ | --------------------------------------------------------------------------- |
| 1    | Open vaccinations while active user is A.  | Empty-state content is shown for user A.                                    |
| 2    | Switch active user to B.                   | No exception occurs while switching.                                        |
| 3    | Return to or refresh vaccinations content. | Vaccinations for user B are shown, and empty-state text for user A is gone. |

Automation target:

- Test file: src/test/presentation/viewmodels/vaccination_viewmodel_test.dart
- Test name: switches from user without vaccinations to user with vaccinations without reinitialization crash
- Test file: src/test/presentation/screens/vaccinations/vaccinations_screen_test.dart
- Test name: while empty state is visible, switching active user updates to vaccination records without crash

## QA-VAX-REG-USER-SWITCH-004

Goal: Verify that switching from one user without vaccinations to another user without vaccinations does not crash and remains in empty state.

Requirement mapping:

- Source files: docs/requirements/product-overview.md, docs/requirements/traceability-matrix.md
- IDs: FR-002, FR-004, AC-006, AC-009, NFR-001

Preconditions:

- Two users exist.
- User A has no vaccination records.
- User B has no vaccination records.

Steps and expected results:

| Step | Action                                     | Expected                                                |
| ---- | ------------------------------------------ | ------------------------------------------------------- |
| 1    | Open vaccinations while active user is A.  | Empty-state content is shown for user A.                |
| 2    | Switch active user to B.                   | No exception occurs while switching.                    |
| 3    | Return to or refresh vaccinations content. | Empty-state content remains visible for user B as well. |

Automation target:

- Test file: src/test/presentation/viewmodels/vaccination_viewmodel_test.dart
- Test name: switches from user without vaccinations to user without vaccinations without reinitialization crash
- Test file: src/test/presentation/screens/vaccinations/vaccinations_screen_test.dart
- Test name: while empty state is visible, switching active user with no records keeps empty state without crash
