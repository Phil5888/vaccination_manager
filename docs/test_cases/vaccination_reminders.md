# Test Cases — Vaccination Reminders

Feature area: reminder computation, lead-time boundary logic, schedule filtering,
and sort ordering for the Schedule screen.

Requirement file: `docs/requirements/vaccination_reminders.md`

---

## Reminder Status Computation

### QA-VAX-REM-001 · Complete series → upToDate

| | |
|---|---|
| **Goal** | A fully administered series with no next-dose date shows as "Up to Date" |
| **Preconditions** | Single shot, past date, no `nextVaccinationDate` |
| **Expected** | `ReminderStatus.upToDate` |
| **Automation** | `test/unit/usecases/get_vaccination_reminders_use_case_test.dart` · *Complete series with no next reminder* |

---

### QA-VAX-REM-002 · Single-shot with overdue next-vaccination-date → overdue

| | |
|---|---|
| **Goal** | A completed series whose next-dose reminder date has passed is flagged overdue |
| **Test data** | `vaccinationDate=yesterday`, `nextVaccinationDate=30 days ago` |
| **Expected** | `ReminderStatus.overdue` |
| **Automation** | `test/presentation/viewmodels/vaccination_reminders_viewmodel_test.dart` · *single-shot with overdue next-vaccination-date → overdue* |

---

### QA-VAX-REM-003 · Next action within lead time → dueSoon

| | |
|---|---|
| **Goal** | A planned shot whose date falls within the configured lead-time window is shown as "Due Soon" |
| **Test data** | `nextActionDate=+30 d`, `leadTimeDays=60` |
| **Expected** | `ReminderStatus.dueSoon` |
| **Automation** | `test/unit/usecases/get_vaccination_reminders_use_case_test.dart` · *nextActionDate within lead time → dueSoon* |

---

### QA-VAX-REM-004 · Next action exactly at today + leadTimeDays → dueSoon (boundary)

| | |
|---|---|
| **Goal** | A shot due on the exact last day of the lead-time window still shows as "Due Soon" |
| **Test data** | `nextActionDate=today+leadTimeDays`, `leadTimeDays=30` |
| **Expected** | `ReminderStatus.dueSoon` |
| **Automation** | `test/unit/usecases/get_vaccination_reminders_use_case_test.dart` · *nextActionDate at leadTimeDays boundary → dueSoon* |

---

### QA-VAX-REM-005 · Next action at today + leadTimeDays + 1 → upToDate

| | |
|---|---|
| **Goal** | A shot due one day beyond the lead-time window is not shown as urgent |
| **Test data** | `nextActionDate=today+leadTimeDays+1` |
| **Expected** | `ReminderStatus.upToDate` |
| **Automation** | `test/unit/usecases/get_vaccination_reminders_use_case_test.dart` · *nextActionDate just beyond lead time → upToDate* |

---

### QA-VAX-REM-006 · Planned shot with no date → upToDate (unscheduled, not urgent)

| | |
|---|---|
| **Goal** | An unscheduled shot (null date) is not considered urgent |
| **Test data** | `vaccinationDate=null` |
| **Expected** | `ReminderStatus.upToDate` or `planned` (not overdue / dueSoon) |
| **Automation** | `test/use_cases/reminder_computation_test.dart` · *Planned shot with no date is not urgent* |

---

## Sort Order

### QA-VAX-REM-007 · Mixed statuses sorted overdue → dueSoon → upToDate

| | |
|---|---|
| **Goal** | Reminders are returned in urgency-descending order |
| **Test data** | Three reminders: one each of overdue, dueSoon, upToDate |
| **Expected** | List order: overdue, dueSoon, upToDate |
| **Automation** | `test/presentation/viewmodels/vaccination_reminders_viewmodel_test.dart` · *mixed statuses returned in order* |

---

### QA-VAX-REM-008 · Within same status, sorted by nextActionDate ASC

| | |
|---|---|
| **Goal** | Among equally urgent reminders, the sooner date comes first |
| **Test data** | Two dueSoon reminders, one at +5 d and one at +10 d |
| **Expected** | +5 d entry first |
| **Automation** | `test/unit/usecases/get_vaccination_reminders_use_case_test.dart` · *Sort: same status sorted by date ASC* |

---

## Lead-Time Settings

### QA-VAX-REM-009 · Respects custom leadTimeDays from settings

| | |
|---|---|
| **Goal** | Changing the lead-time setting affects which reminders are marked dueSoon |
| **Test data** | Shot +20 days away; compare leadTimeDays=30 vs leadTimeDays=7 |
| **Expected** | `dueSoon` at 30 days, `upToDate` at 7 days |
| **Automation** | `test/presentation/viewmodels/vaccination_reminders_viewmodel_test.dart` · *respects custom lead time from settings* |

---

## Schedule Filtering

### QA-VAX-REM-010 · filter=all returns all reminders

| | |
|---|---|
| **Goal** | The "All" filter on the Schedule screen shows every reminder |
| **Automation** | `test/presentation/viewmodels/vaccination_reminders_viewmodel_test.dart` · *filter=all returns all reminders* |

---

### QA-VAX-REM-011 · filter=overdue returns only overdue reminders

| | |
|---|---|
| **Goal** | The "Overdue" filter shows only overdue reminders |
| **Automation** | `test/presentation/viewmodels/vaccination_reminders_viewmodel_test.dart` · *filter=overdue returns only overdue reminders* |
