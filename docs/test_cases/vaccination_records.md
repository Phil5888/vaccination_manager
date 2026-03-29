# Test Cases — Vaccination Records

Feature area: adding, editing, deleting vaccination records and recording individual shots
within a multi-shot series.

Requirement file: `docs/requirements/vaccination_records.md`

---

## Add — Single Shot

### QA-VAX-REC-ADD-001 · Save single shot with past date

| | |
|---|---|
| **Goal** | A past-dated single shot is persisted and visible in the records list |
| **Preconditions** | Active user has no existing records |
| **Test data** | `name="Flu"`, `shotDate=yesterday`, `totalShots=1` |
| **Steps** | 1. Call `saveSeries([singleShotPast])` on `VaccinationViewModel` |
| **Expected** | Entry appears in state; `seriesStatus == complete` |
| **Automation** | `test/use_cases/add_vaccination_single_shot_test.dart` · *Save single shot with past date* |

---

### QA-VAX-REC-ADD-002 · Save single shot with future date

| | |
|---|---|
| **Goal** | A future-dated shot is stored and shown as "Planned" |
| **Preconditions** | Active user has no existing records |
| **Test data** | `shotDate=+30 days`, `totalShots=1` |
| **Steps** | 1. Call `saveSeries([singleShotFuture])` |
| **Expected** | Entry in state; `seriesStatus == planned` |
| **Automation** | `test/use_cases/add_vaccination_single_shot_test.dart` · *Save single shot with future date* |

---

### QA-VAX-REC-ADD-003 · Save with null date (unscheduled)

| | |
|---|---|
| **Goal** | An unscheduled shot (no date) is stored and shown as "Planned" |
| **Test data** | `vaccinationDate=null`, `totalShots=1` |
| **Expected** | `seriesStatus == planned` |
| **Automation** | `test/use_cases/add_vaccination_single_shot_test.dart` · *Save with null date* |

---

### QA-VAX-REC-ADD-004 · Save with next-dose reminder

| | |
|---|---|
| **Goal** | `nextVaccinationDate` is stored when the user sets a next-dose reminder |
| **Test data** | `vaccinationDate=yesterday`, `nextVaccinationDate=+1 year` |
| **Expected** | `shots.first.nextVaccinationDate` equals the stored date |
| **Automation** | `test/use_cases/add_vaccination_single_shot_test.dart` · *Save with next-dose reminder* |

---

### QA-VAX-REC-ADD-005 · Empty vaccine name is rejected

| | |
|---|---|
| **Goal** | Saving with an empty name does not persist any entry |
| **Test data** | `name=""` |
| **Expected** | `ValidationException` thrown; repository unchanged |
| **Automation** | `test/use_cases/add_vaccination_single_shot_test.dart` · *Empty vaccine name is rejected* |

---

### QA-VAX-REC-ADD-006 · Whitespace-only name is rejected

| | |
|---|---|
| **Goal** | Whitespace-only name treated as invalid |
| **Test data** | `name="   "` |
| **Expected** | `ValidationException`; nothing saved |
| **Automation** | `test/use_cases/add_vaccination_single_shot_test.dart` · *Whitespace-only vaccine name is rejected* |

---

## Add — Multi-Shot

### QA-VAX-REC-MULTI-001 · 3 shots, all past → complete

| | |
|---|---|
| **Goal** | A fully administered 3-shot series is marked complete |
| **Test data** | Shot 1: −60 d, Shot 2: −30 d, Shot 3: −7 d |
| **Expected** | `seriesStatus == complete`; `completedShots == 3` |
| **Automation** | `test/use_cases/add_vaccination_multi_shot_test.dart` · *3 shots all past dates*  |

---

### QA-VAX-REC-MULTI-002 · 3 shots, mixed dates → inProgress

| | |
|---|---|
| **Goal** | A partially administered series is marked "In Progress" |
| **Test data** | Shot 1: yesterday, Shot 2: +30 d, Shot 3: null |
| **Expected** | `seriesStatus == inProgress`; `completedShots == 1` |
| **Automation** | `test/use_cases/add_vaccination_multi_shot_test.dart` · *1 past + 1 future + 1 null* |

---

### QA-VAX-REC-MULTI-003 · 3 shots, all null → planned

| | |
|---|---|
| **Goal** | A series with no dates is stored as "Planned" |
| **Test data** | All `vaccinationDate=null` |
| **Expected** | `seriesStatus == planned`; `completedShots == 0` |
| **Automation** | `test/use_cases/add_vaccination_multi_shot_test.dart` · *3 null-date shots* |

---

### QA-VAX-REC-MULTI-004 · Shot 2 before Shot 1 → validation error

| | |
|---|---|
| **Goal** | Date ordering is enforced: later shots cannot predate earlier ones |
| **Test data** | Shot 1: today, Shot 2: yesterday |
| **Expected** | `ValidationException`; nothing saved |
| **Automation** | `test/use_cases/add_vaccination_multi_shot_test.dart` · *Shot 2 before shot 1 is invalid* |

---

### QA-VAX-REC-MULTI-005 · Shot 3 before Shot 2 → validation error

| | |
|---|---|
| **Test data** | Shot 2: today, Shot 3: yesterday |
| **Expected** | `ValidationException` |
| **Automation** | `test/use_cases/add_vaccination_multi_shot_test.dart` · *Shot 3 before shot 2 is invalid* |

---

### QA-VAX-REC-MULTI-006 · Same date for adjacent shots is valid

| | |
|---|---|
| **Goal** | Equal dates across consecutive shots are allowed |
| **Test data** | Shot 1: today, Shot 2: today |
| **Expected** | No error; both shots saved |
| **Automation** | `test/use_cases/add_vaccination_multi_shot_test.dart` · *Shot 2 same day as shot 1 is valid* |

---

### QA-VAX-REC-MULTI-007 · Null shots between dated shots do not trigger ordering error

| | |
|---|---|
| **Goal** | A null-date shot between two dated shots is allowed |
| **Test data** | Shot 1: yesterday, Shot 2: null, Shot 3: tomorrow |
| **Expected** | Saved without error |
| **Automation** | `test/use_cases/add_vaccination_multi_shot_test.dart` · *Null shot between dated shots* |

---

## Edit

### QA-VAX-REC-EDIT-001 · Rename vaccine

| | |
|---|---|
| **Goal** | Renaming replaces the old series with a new-name series |
| **Expected** | Old name gone; new name present; shot data preserved |
| **Automation** | `test/use_cases/edit_vaccination_series_test.dart` · *Edit vaccine name* |

---

### QA-VAX-REC-EDIT-002 · Reduce shot count

| | |
|---|---|
| **Goal** | Reducing from 3 → 2 shots removes the third entry |
| **Expected** | Only 2 shots remain; no orphan entries |
| **Automation** | `test/use_cases/edit_vaccination_series_test.dart` · *Reduce shot count* |

---

### QA-VAX-REC-EDIT-003 · Increase shot count

| | |
|---|---|
| **Goal** | Increasing from 1 → 3 adds 2 null-date placeholder shots |
| **Expected** | 3 shots total; new shots have `vaccinationDate == null` |
| **Automation** | `test/use_cases/edit_vaccination_series_test.dart` · *Increase shot count* |

---

### QA-VAX-REC-EDIT-004 · Edit a shot date

| | |
|---|---|
| **Goal** | Updating a shot's date is reflected in status |
| **Expected** | Status transitions correctly after date change |
| **Automation** | `test/use_cases/edit_vaccination_series_test.dart` · *Edit shot date* |

---

## Delete

### QA-VAX-REC-DEL-001 · Delete removes all shots in series

| | |
|---|---|
| **Goal** | All shots for the named vaccine are removed |
| **Expected** | Empty list for that vaccine; no dangling entries |
| **Automation** | `test/use_cases/delete_vaccination_series_test.dart` · *Delete series removes all shots* |

---

### QA-VAX-REC-DEL-002 · Delete does not affect other vaccines

| | |
|---|---|
| **Goal** | Only the target vaccine's shots are removed |
| **Expected** | Other vaccine shots unaffected |
| **Automation** | `test/use_cases/delete_vaccination_series_test.dart` · *Delete does not affect another vaccine* |

---

### QA-VAX-REC-DEL-003 · Delete on non-existent series is safe

| | |
|---|---|
| **Goal** | Deleting a series that doesn't exist does not throw |
| **Expected** | No exception; repository unchanged |
| **Automation** | `test/use_cases/delete_vaccination_series_test.dart` · *Delete on non-existent series does not throw* |

---

### QA-VAX-REC-DEL-004 · Delete is case-insensitive on vaccine name

| | |
|---|---|
| **Goal** | Deleting `"flu"` also removes shots stored under `"Flu"` or `"FLU"` |
| **Test data** | Shot saved as `"Flu"`, delete called with `"flu"` |
| **Expected** | All shots for that name removed; repository is empty |
| **Automation** | `test/use_cases/delete_vaccination_series_test.dart` · *case-insensitive name match deletes correctly* |

---

## Record Next Shot

### QA-VAX-REC-RNXT-001 · Record next shot on planned series

| | |
|---|---|
| **Goal** | Recording the first shot of a planned series advances status |
| **Expected** | `seriesStatus` transitions to `inProgress` or `complete` |
| **Automation** | `test/use_cases/record_next_shot_test.dart` · *Record next shot transitions status* |

---

### QA-VAX-REC-RNXT-002 · Record last remaining shot → complete

| | |
|---|---|
| **Goal** | Recording the final shot marks the series complete |
| **Expected** | `seriesStatus == complete`; `completedShots == totalShots` |
| **Automation** | `test/use_cases/record_next_shot_test.dart` · *Recording last shot completes series* |

---

### QA-VAX-REC-RNXT-003 · Record shot updates only the target entry

| | |
|---|---|
| **Goal** | Other shots in the series are not modified |
| **Expected** | Only the targeted shot has a new date |
| **Automation** | `test/use_cases/record_next_shot_test.dart` · *Record shot updates only target shot* |
