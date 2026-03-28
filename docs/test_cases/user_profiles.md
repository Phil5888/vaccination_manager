# Test Cases — User Profiles

Feature area: profile creation, active user switching, per-user data isolation.

Requirement file: `docs/requirements/user_profiles.md`

> Previously documented in `docs/test_use_cases.md` as `QA-VAX-REG-USER-SWITCH-001..004`.
> Migrated here with updated IDs; the original IDs are preserved in parentheses for traceability.

---

## User Switching

### QA-VAX-USR-001 (was QA-VAX-REG-USER-SWITCH-001) · Switch from user with records to user with records

| | |
|---|---|
| **Goal** | Switching active users shows only the new user's records |
| **Preconditions** | User A has ≥1 vaccination record; User B has ≥1 vaccination record |
| **Steps** | 1. Set active user = A; load records → assert A's records shown<br>2. Set active user = B; load records → assert B's records shown |
| **Expected** | Each user sees only their own records; no data leak |
| **Automation** | `test/use_cases/switch_active_user_test.dart` · *User A (records) → User B (records): shows only B's records* |

---

### QA-VAX-USR-002 (was QA-VAX-REG-USER-SWITCH-002) · Switch from user with records to user with no records

| | |
|---|---|
| **Goal** | Switching to a user with no records shows empty state |
| **Preconditions** | User A has ≥1 record; User B has 0 records |
| **Expected** | After switch: empty list returned for User B |
| **Automation** | `test/use_cases/switch_active_user_test.dart` · *User A (records) → User B (no records): empty state* |

---

### QA-VAX-USR-003 (was QA-VAX-REG-USER-SWITCH-003) · Switch from user with no records to user with records

| | |
|---|---|
| **Goal** | Switching to a user with records shows their records immediately |
| **Preconditions** | User A has 0 records; User B has ≥1 record |
| **Expected** | After switch: B's records shown |
| **Automation** | `test/use_cases/switch_active_user_test.dart` · *User A (no records) → User B (records): records shown* |

---

### QA-VAX-USR-004 (was QA-VAX-REG-USER-SWITCH-004) · Switch from user with no records to user with no records

| | |
|---|---|
| **Goal** | Empty state persists when both users have no records |
| **Preconditions** | Neither User A nor User B has records |
| **Expected** | Empty list for both |
| **Automation** | `test/use_cases/switch_active_user_test.dart` · *User A (no records) → User B (no records): both empty* |

---

## Data Isolation (ViewModel level)

### QA-VAX-USR-005 · saveSeries for User A does not affect User B

| | |
|---|---|
| **Goal** | User A's records are isolated from User B's at the viewmodel level |
| **Preconditions** | Separate `ProviderContainer` instances per user (or mid-test user switch) |
| **Expected** | User B's entry count unchanged after User A saves |
| **Automation** | `test/presentation/viewmodels/vaccination_viewmodel_test.dart` · *saveSeries() does not affect another user's entries* |
