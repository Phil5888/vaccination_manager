# Permissions Reference

This document lists every permission VaccineCare requests, the reason it is needed, whether it
is strictly required or optional, what data is accessed, and whether that data ever leaves the
device. It is intended as the single source of truth for app-store privacy questionnaires and
internal privacy reviews.

**Privacy principle:** VaccineCare stores all health data locally on the device. No permission
grants access to a remote server, third-party SDK, or analytics system.

---

## Summary table

| Platform | Permission | Feature | Required? |
|---|---|---|---|
| Android | `READ_CALENDAR` | Calendar sync | Optional |
| Android | `WRITE_CALENDAR` | Calendar sync | Optional |
| Android | `POST_NOTIFICATIONS` | Dose reminders | Optional |
| Android | `RECEIVE_BOOT_COMPLETED` | Restore reminders after reboot | Optional (depends on reminders) |
| Android | `USE_EXACT_ALARM` | Exact-time dose reminders | Optional (depends on reminders) |
| Android | `VIBRATE` | Notification vibration | Optional (depends on reminders) |
| iOS | `NSCalendarsUsageDescription` | Calendar sync | Optional |
| iOS | `NSCalendarsWriteOnlyAccessUsageDescription` | Calendar sync | Optional |
| iOS | `NSUserNotificationUsageDescription` | Dose reminders | Optional |
| macOS | *(no calendar entitlement — see gap below)* | — | — |

---

## Android

### `READ_CALENDAR`
- **Why:** Read the user's calendar list so the app can let them choose which calendar to add
  vaccination events to.
- **Data accessed:** Calendar titles and IDs only. No event content is read.
- **Leaves device:** No.
- **Required:** No. Calendar sync is a user-initiated, opt-in feature. The app functions fully
  without it.
- **Declared in:** `android/app/src/main/AndroidManifest.xml`
- **Used by:** `NativeCalendarRepositoryImpl.retrieveCalendars()`

### `WRITE_CALENDAR`
- **Why:** Create and delete vaccination reminder events in the user's chosen calendar.
- **Data accessed:** Only the events VaccineCare writes itself (vaccination name, date, notes).
- **Leaves device:** No.
- **Required:** No. Same opt-in as above.
- **Declared in:** `android/app/src/main/AndroidManifest.xml`
- **Used by:** `NativeCalendarRepositoryImpl.createOrUpdateEvent()`, `.deleteEvent()`

### `POST_NOTIFICATIONS`
- **Why:** Send local (on-device) push notifications for upcoming vaccination doses.
- **Data accessed:** Nothing; the notification payload is generated locally from the app's own
  SQLite data.
- **Leaves device:** No.
- **Required:** No. Users who decline this permission simply don't receive reminder notifications.
- **When requested:** Prompted at runtime the first time the user enables reminders (Android 13+).
  Silently granted on Android 12 and below.
- **Declared in:** `android/app/src/main/AndroidManifest.xml`
- **Used by:** `LocalNotificationRepositoryImpl.requestPermission()`

### `RECEIVE_BOOT_COMPLETED`
- **Why:** After a device reboot, Android cancels all pending alarms. This permission lets the
  app re-register scheduled notifications when the device starts.
- **Data accessed:** Only the device boot broadcast; no user data is read.
- **Leaves device:** No.
- **Required:** Only if the user has reminders enabled. Otherwise inert.
- **Declared in:** `android/app/src/main/AndroidManifest.xml`
- **Used by:** `flutter_local_notifications` boot receiver, registered in the manifest.
- **App Store note:** This is a common, low-risk permission. No special declaration needed for
  the Play Store.

### `USE_EXACT_ALARM`
- **Why:** Vaccination reminders must fire at the exact scheduled time, not in a batch
  maintenance window. This permission enables `AndroidScheduleMode.exactAllowWhileIdle`.
- **Data accessed:** None.
- **Leaves device:** No.
- **Required:** Only if the user has reminders enabled.
- **Declared in:** `android/app/src/main/AndroidManifest.xml`
- **Used by:** `LocalNotificationRepositoryImpl.scheduleNotification()`
- **⚠️ Play Store note:** As of Android 13 / API 33 this permission is in the `NORMAL`
  protection level for apps whose core function is scheduling (reminders, calendars). VaccineCare
  qualifies. However, Google Play may ask for written justification during the app review process.
  Suggested wording: *"VaccineCare schedules vaccination reminders at precise times defined by
  the user. Delivering them hours late defeats the safety purpose of the feature."*

### `VIBRATE`
- **Why:** Allows notifications to include vibration feedback.
- **Data accessed:** None.
- **Leaves device:** No.
- **Required:** No. Silently granted; users can disable vibration in system settings.
- **Declared in:** `android/app/src/main/AndroidManifest.xml`
- **Used by:** `flutter_local_notifications` (implicit in `AndroidNotificationDetails`).

---

## iOS

All three keys are declared in `ios/Runner/Info.plist` and shown to the user in the system
permission dialog exactly as written below.

### `NSCalendarsUsageDescription`
- **Shown to user:** *"VaccineCare uses your calendar to add vaccination reminders so you never
  miss a dose."*
- **Why:** iOS 17+ requires a full-access description even if the app only reads the calendar
  list for a picker.
- **Data accessed:** Calendar titles and IDs only.
- **Leaves device:** No.
- **Required:** No. Calendar sync is opt-in.

### `NSCalendarsWriteOnlyAccessUsageDescription`
- **Shown to user:** *"VaccineCare adds vaccination appointments to your calendar."*
- **Why:** iOS 17+ lets users grant write-only access without exposing existing events. VaccineCare
  only creates new events, so write-only is sufficient and preferable from a privacy standpoint.
- **Data accessed:** Only events the app creates itself.
- **Leaves device:** No.
- **Required:** No.

### `NSUserNotificationUsageDescription`
- **Shown to user:** *"VaccineCare sends reminders before upcoming vaccinations."*
- **Why:** Required to schedule local notifications.
- **Data accessed:** Nothing; payload is constructed locally.
- **Leaves device:** No.
- **Required:** No. The app works without notifications; users who decline miss reminders.

---

## macOS

macOS apps are sandboxed. Beyond the entitlements listed here, the OS blocks all sensitive
resource access.

### Current entitlements (`macos/Runner/Release.entitlements`)

| Entitlement | Value | Purpose |
|---|---|---|
| `com.apple.security.app-sandbox` | `true` | Standard sandboxing (required for Mac App Store) |

### ⚠️ Known gap — calendar access entitlement missing

The `device_calendar` plugin on macOS requires the
`com.apple.security.personal-information.calendars` entitlement to access the system calendar
from within the sandbox. Without it, `retrieveCalendars()` and `createOrUpdateEvent()` will
silently fail at runtime.

**Required fix before macOS release:**
Add to both `DebugProfile.entitlements` **and** `Release.entitlements`:
```xml
<key>com.apple.security.personal-information.calendars</key>
<true/>
```

This entitlement is also required for Mac App Store submission. Apple will ask for a usage
justification during review — the same wording as `NSCalendarsWriteOnlyAccessUsageDescription`
applies.

### Debug-only entitlements (`macos/Runner/DebugProfile.entitlements`)

| Entitlement | Value | Purpose |
|---|---|---|
| `com.apple.security.cs.allow-jit` | `true` | Flutter hot reload (dev only) |
| `com.apple.security.network.server` | `true` | Flutter dev server (dev only) |

These are **not** present in `Release.entitlements` and are never shipped.

---

## Permissions not requested

The following sensitive permissions are **not** requested by this app. This list is useful for
app-store privacy labels.

| Category | Permission | Reason not needed |
|---|---|---|
| Location | `ACCESS_FINE_LOCATION` / `NSLocationUsageDescription` | App has no location features |
| Contacts | `READ_CONTACTS` / `NSContactsUsageDescription` | User profiles are typed manually |
| Camera | `CAMERA` / `NSCameraUsageDescription` | No photo or QR features |
| Microphone | `RECORD_AUDIO` / `NSMicrophoneUsageDescription` | No audio features |
| Biometrics | `USE_BIOMETRIC` / `NSFaceIDUsageDescription` | No biometric auth (yet) |
| Internet | `INTERNET` | All data is local; no network calls |
| Storage read | `READ_EXTERNAL_STORAGE` | Not needed; share_plus uses system share sheet |
| Tracking | `AppTrackingTransparency` | No advertising or cross-app tracking |

---

## App-store privacy labels

### Google Play — Data safety

| Data type | Collected | Shared | Purpose |
|---|---|---|---|
| Health info (vaccination records) | Yes — stored locally | No | App functionality |
| Calendar events | Yes — written to device calendar on request | No | App functionality |
| Personal info (user name) | Yes — stored locally | No | App functionality |

**Data is not encrypted in transit** (no transit occurs). Data is encrypted at rest only if the
device has full-disk encryption enabled (Android default since API 23).

### Apple — Privacy nutrition label

| Category | Status | Notes |
|---|---|---|
| Data not collected | ✅ | No data leaves the device |
| Data not linked to identity | ✅ | No account, no analytics SDK |
| No tracking | ✅ | `NSUserTrackingUsageDescription` not declared |

---

## Open questions / decisions before store release

1. **Biometric lock** — If a PIN / Face ID lock feature is added in the future,
   `USE_BIOMETRIC` (Android) and `NSFaceIDUsageDescription` (iOS) must be added.
2. **macOS calendar entitlement** — Must be added before any macOS release (see gap above).
3. **Android `USE_EXACT_ALARM` Play Store review** — Prepare the written justification text
   (suggested wording above) for the Data safety form or app review team questionnaire.
4. **Export / backup** — If a cloud backup feature is added, the `INTERNET` permission and
   privacy label entries must be updated accordingly.
