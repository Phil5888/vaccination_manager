# Test Cases — Widget & Screen Tests

Feature area: UI rendering, navigation flows, and screen-level integration using
`ProviderScope` with fake repositories. All tests use `flutter_test` + `testWidgets`.

---

## Navigation — Main Shell

File: `test/presentation/screens/main_screen_navigation_test.dart`

| Test ID | Test name | Goal |
|---|---|---|
| QA-NAV-001 | *FAB is shown on Dashboard tab (index 0)* | FAB is visible on Dashboard |
| QA-NAV-002 | *FAB is NOT shown on Profile tab (index 3)* | FAB is hidden on non-content tabs |
| QA-NAV-003 | *tapping FAB on Records tab navigates to AddVaccinationScreen* | FAB tap triggers correct route |
| QA-NAV-004 | *tapping FAB on Schedule tab navigates to AddVaccinationScreen* | FAB tap from Schedule also goes to AddVaccination |
| QA-NAV-005 | *AddVaccinationScreen can be popped back to MainScreen* | Back navigation works from add form |

---

## Dashboard Screen

File: `test/presentation/screens/dashboard_screen_test.dart`

| Test ID | Test name | Goal |
|---|---|---|
| QA-DASH-001 | *renders at [phone/tablet/desktop sizes]* | No overflow or layout errors at standard breakpoints |
| QA-DASH-002 | *key text widgets are findable in dark mode* | Dark-mode build has same structural widgets |
| QA-DASH-003 | *no overflow at phoneSmall × [scale]* | Smallest supported viewport does not overflow |

---

## Records Screen

File: `test/presentation/screens/records_screen_test.dart`

| Test ID | Test name | Goal |
|---|---|---|
| QA-REC-SCR-001 | *renders at [phone/tablet/desktop sizes]* | No overflow at standard breakpoints (empty state) |
| QA-REC-SCR-002 | *renders at [sizes] with data* | No overflow at standard breakpoints when data is present |
| QA-REC-SCR-003 | *10 series × 3 shots renders without overflow at phoneSmall* | Long list of cards does not overflow |
| QA-REC-SCR-004 | *no overflow for user 1 (Alice, 40 shots)* | Realistic large dataset (40 shots) renders cleanly |
| QA-REC-SCR-005 | *no overflow for user 2 (Bob, 35 shots)* | Realistic large dataset (35 shots) renders cleanly |
| QA-REC-SCR-006 | *no overflow for user 3 (Charlie, 25 shots)* | Realistic large dataset (25 shots) renders cleanly |
| QA-REC-SCR-007 | *user 1/2/3 raw shot count is N* | Fixture data integrity — shot counts match expectations |

---

## Schedule Screen

File: `test/presentation/screens/schedule_screen_test.dart`

| Test ID | Test name | Goal |
|---|---|---|
| QA-SCH-SCR-001 | *renders at [phone/tablet/desktop sizes]* | No overflow at standard breakpoints (empty state) |
| QA-SCH-SCR-002 | *renders at [sizes] with data* | No overflow at standard breakpoints when data is present |
| QA-SCH-SCR-003 | *no overflow for user 1 (Alice) at phoneSmall* | Realistic dataset renders at smallest viewport |
| QA-SCH-SCR-004 | *no overflow for user 2 (Bob) at phoneSmall* | Realistic dataset renders at smallest viewport |
| QA-SCH-SCR-005 | *no overflow for user 3 (Charlie) at phoneSmall* | Realistic dataset renders at smallest viewport |

---

## Add Vaccination Screen

File: `test/presentation/screens/add_vaccination_screen_test.dart`

| Test ID | Test name | Goal |
|---|---|---|
| QA-ADD-SCR-001 | *renders at [phone/tablet/desktop sizes]* | Form renders at standard breakpoints |
| QA-ADD-SCR-002 | *renders 59-char vaccine name without overflow at phoneSmall* | Long vaccine name text does not overflow on smallest viewport |

---

## Profile Screen

File: `test/presentation/screens/profile_screen_test.dart`

| Test ID | Test name | Goal |
|---|---|---|
| QA-PROF-SCR-001 | *renders at [phone/tablet/desktop sizes]* | Profile screen renders at standard breakpoints |
| QA-PROF-SCR-002 | *renders with user data* | Profile screen with a loaded user renders without errors |
| QA-PROF-SCR-003 | *shows empty state / create profile prompt when no user* | Unauthenticated state shows correct fallback UI |

---

## VaccinationSeriesCard Widget

File: `test/presentation/widgets/vaccination_series_card_test.dart`

| Test ID | Test name | Goal |
|---|---|---|
| QA-CARD-001 | *renders series name and shot count* | Key data is visible in card |
| QA-CARD-002 | *shows correct status badge* | Status chip reflects series status |
| QA-CARD-003 | *onDelete callback fires on delete button tap* | Delete button is wired — callback is invoked (regression guard for dead-code bug) |

---

## Notes

- All screen tests use `ProviderScope` with overridden providers backed by in-memory fakes.
- Viewport sizes are defined in `test/helpers/screen_sizes.dart` and cover phoneSmall (320×568), phone (390×844), tablet (768×1024), desktop (1280×800).
- Screen tests do not hit the SQLite database; they exercise the full widget tree including `AppRouter` but with injected state.
