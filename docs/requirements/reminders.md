# Reminder & Calendar Sync Requirements

## Context

Users need timely, actionable reminders about upcoming and overdue vaccinations. The feature
delivers reminders through three complementary channels: local push notifications scheduled ahead
of time, native device calendar events, and a persistent overdue badge on the main navigation.
All reminder behaviour is driven by vaccination shot data already stored in the app; no external
server is required.

## Scope

- **In scope:** local push notification scheduling and cancellation; native calendar event
  creation and deletion (iOS/Android); cross-platform `.ics` export for calendar apps
  (macOS/Windows/Web); per-user reminder settings persisted locally; overdue badge on the
  Schedule navigation tab.
- **Out of scope:** server-side push notifications, email or SMS reminders, third-party calendar
  API integrations (e.g. Google Calendar REST API), and badge counts on the OS app icon.

## User Stories

- As a user, I want to receive a push notification before a scheduled vaccination so that I do not
  forget to attend.
- As a user, I want to choose how many days in advance I am reminded so that the notification fits
  my planning style.
- As a user, I want upcoming vaccinations added to my device calendar so that they appear
  alongside my other appointments.
- As a user on a platform without native calendar access, I want to export a `.ics` file so that I
  can import the vaccination event into any calendar application.
- As a user, I want a badge on the Schedule tab to show how many vaccinations are overdue so that I
  can act on them immediately without opening the schedule.
- As a user, I want reminders and calendar events to be removed automatically when I delete a
  vaccination so that I am not left with stale entries.

## Functional Requirements

### Notifications

- **REM-001** — The system shall schedule a local push notification for each future-dated
  vaccination shot when reminders are enabled.
- **REM-002** — Notifications shall be scheduled at the user-configured time of day (hour and
  minute) on the date that is `reminderAdvanceDays` before the shot date.
- **REM-003** — When notifications are disabled in settings, no new notifications shall be
  scheduled and any previously scheduled notifications shall be cancelled.
- **REM-004** — Each notification shall carry a stable, deterministic ID derived from the shot
  record so that rescheduling the same shot replaces, rather than duplicates, its notification.

### Calendar Sync

- **REM-005** — On platforms with native calendar access (iOS and Android), the system shall
  create a device calendar event for each future-dated shot when calendar sync is enabled.
- **REM-006** — On platforms without native calendar access (macOS, Windows, Web), the system
  shall provide a per-series "Export to calendar" action that generates a valid RFC-5545 `.ics`
  file and shares it via the platform share sheet.
- **REM-007** — Calendar sync shall be idempotent: syncing the same shot data multiple times
  shall not create duplicate calendar events. Each sync operation shall delete all stale calendar
  events for the affected series before creating fresh ones.
- **REM-008** — Only shots whose vaccination date or next vaccination date is in the future shall
  be included in calendar sync or notification scheduling. Past-dated shots and shots where both
  date fields are null shall be excluded.

### Sync Trigger Lifecycle

- **REM-009** — After a vaccination series is successfully saved, the system shall automatically
  run a full calendar-and-notification sync for that series.
- **REM-010** — Before a vaccination series or individual shot is deleted from the database, the
  system shall cancel all associated scheduled notifications.
- **REM-011** — Calendar sync failures shall not prevent a save operation from completing.
  Sync errors shall be handled silently (best-effort).

### Settings

- **REM-012** — The system shall expose the following user-configurable reminder settings,
  persisted locally across app restarts:

  | Setting key              | Type | Valid range / default   | Purpose                                    |
  | ------------------------ | ---- | ----------------------- | ------------------------------------------ |
  | `notificationsEnabled`   | bool | —&nbsp;/ default `true` | Master toggle for push notifications       |
  | `calendarSyncEnabled`    | bool | —&nbsp;/ default `false`| Toggle for native calendar sync            |
  | `reminderAdvanceDays`    | int  | 1–30 / default `7`      | Days before shot date to deliver reminder  |
  | `notificationHour`       | int  | 0–23 / default `9`      | Hour of day for the notification           |
  | `notificationMinute`     | int  | 0–59 / default `0`      | Minute of day for the notification         |

- **REM-013** — Changing any reminder setting shall take effect for all subsequent sync
  operations without requiring an app restart.

### Overdue Badge

- **REM-014** — The Schedule navigation tab shall display a badge showing the count of
  vaccination shots whose reminder status is overdue.
- **REM-015** — The badge shall update reactively whenever the underlying vaccination data or
  reminder status changes.
- **REM-016** — When there are no overdue shots the badge shall not be displayed.

## Non-Functional Requirements

- **REM-NFR-001** — Notification IDs shall be computed deterministically from stable shot
  attributes so that the same shot always maps to the same notification ID across app sessions,
  enabling reliable replacement and cancellation without a separate lookup table.
- **REM-NFR-002** — All reminder settings shall be persisted locally (e.g. SharedPreferences or
  equivalent) and survive app restarts without requiring a network call.
- **REM-NFR-003** — The `.ics` files produced by the export action shall conform to RFC-5545
  and be importable by mainstream calendar applications (Apple Calendar, Google Calendar,
  Microsoft Outlook).
- **REM-NFR-004** — The calendar-and-notification sync operation shall complete without
  perceptible UI blocking; failures shall never surface as unhandled exceptions to the user.
- **REM-NFR-005** — The sync record store (`calendar_sync_records`) shall be the authoritative
  source for which calendar events and notifications are currently active, enabling full cleanup
  even if the original shot data has changed.

## Acceptance Criteria

| ID     | Requirement | Criterion |
| ------ | ----------- | --------- |
| AC-REM-001 | REM-001, REM-002 | Given notifications are enabled and a shot is saved with a future date, a push notification is scheduled at the configured hour/minute on the date that is `reminderAdvanceDays` before the shot date. |
| AC-REM-002 | REM-003 | Given notifications are disabled, toggling the setting off cancels all previously scheduled notifications and no new notifications are scheduled on subsequent saves. |
| AC-REM-003 | REM-004 | Saving the same shot twice does not create a duplicate notification; the second save replaces the first. |
| AC-REM-004 | REM-005 | Given calendar sync is enabled on iOS or Android, saving a series with a future shot creates a calendar event on the device calendar. |
| AC-REM-005 | REM-006 | On macOS, Windows, or Web, tapping "Export to calendar" on a series card produces a downloadable/shareable `.ics` file containing the relevant shot event(s). |
| AC-REM-006 | REM-007 | Saving a series that was previously synced results in exactly one calendar event per future shot (stale events are removed before new ones are created). |
| AC-REM-007 | REM-008 | A shot whose `vaccinationDate` is in the past is not added to the calendar and no notification is scheduled for it. |
| AC-REM-008 | REM-008 | A shot where both `vaccinationDate` and `nextVaccinationDate` are null is not synced or scheduled. |
| AC-REM-009 | REM-009 | Immediately after a successful series save, calendar events and notifications reflect the current state of that series without manual user action. |
| AC-REM-010 | REM-010 | Deleting a vaccination series cancels all associated scheduled notifications before the database rows are removed. |
| AC-REM-011 | REM-011 | A calendar sync failure (e.g. permission denied) does not show an error dialog or prevent the save confirmation from completing. |
| AC-REM-012 | REM-012 | All five reminder settings are stored and retrieved correctly across an app restart; their defaults match specified values when first launched. |
| AC-REM-013 | REM-013 | Changing `reminderAdvanceDays` and then saving a series schedules the notification at the new lead-day offset, not the old one. |
| AC-REM-014 | REM-014, REM-016 | The Schedule tab badge displays the correct overdue count when at least one shot is overdue, and is hidden when no shots are overdue. |
| AC-REM-015 | REM-015 | Adding a new overdue shot updates the Schedule tab badge count without requiring a screen reload or app restart. |
| AC-REM-016 | REM-NFR-003 | The exported `.ics` file passes RFC-5545 validation and can be imported into Apple Calendar, Google Calendar, or Outlook without errors. |

## Technical Notes

> This section records implementation constraints that are relevant for traceability but are
> intentionally kept separate from the functional requirements above.

- **Notification ID formula:** `shot.id * 100 + shot.shotNumber`. This produces a stable,
  collision-free ID for shot IDs below approximately 21,000,000. If the shot ID ceiling is
  expected to be exceeded, the formula must be revisited before that threshold is reached.
- **Sync record table:** `calendar_sync_records` maps shot IDs to their active calendar event IDs
  and notification IDs. It is the source of truth for cleanup operations.
- **Platform routing:** Native calendar access uses the `device_calendar` package on iOS/Android.
  The `.ics` export path uses `share_plus` and is the only calendar integration on
  macOS/Windows/Web.
- **Settings storage:** `SharedPreferences` is the current persistence mechanism for all five
  reminder settings.

## Open Questions

- Should the user be prompted to grant notification permissions on first launch, or only when they
  first enable notifications in settings?
- Should the overdue badge count be capped at a display maximum (e.g. "9+") for large overdue
  counts?
- Should calendar events include a reminder/alarm embedded in the `.ics` file, or only a plain
  event entry?
- Is there a requirement to sync calendar events for shots that are due soon but not yet past, or
  only strictly future shots relative to today?

## Change Log

- 2026-05-30: Initial requirements file created, covering local notifications, native calendar
  sync, `.ics` export, reminder settings, overdue badge, and sync lifecycle.
