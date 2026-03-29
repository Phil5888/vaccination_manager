// Tests for the three notification/calendar use cases:
//   1. ExportIcsUseCase           – pure Dart, RFC-5545 ICS output
//   2. SyncCalendarUseCase        – idempotent sync (fakes for all three repos)
//   3. CancelNotificationsUseCase – cancels stale events and notifications
//
// All dependencies are covered by hand-written fakes defined in this file.
// No Mockito, no @GenerateMocks, no build_runner.

import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/notification_preference_entity.dart';
import 'package:vaccination_manager/domain/entities/synced_event_record.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/calendar_repository.dart';
import 'package:vaccination_manager/domain/repositories/notification_repository.dart';
import 'package:vaccination_manager/domain/repositories/synced_event_repository.dart';
import 'package:vaccination_manager/domain/usecases/notifications/cancel_notifications_use_case.dart';
import 'package:vaccination_manager/domain/usecases/notifications/export_ics_use_case.dart';
import 'package:vaccination_manager/domain/usecases/notifications/sync_calendar_use_case.dart';

// =============================================================================
// Fakes
// =============================================================================

/// In-memory [CalendarRepository] that records every call for later assertion.
///
/// [supportsNative] controls the [supportsNativeCalendar] getter so tests can
/// exercise the platform-guard path in [SyncCalendarUseCase].
class FakeCalendarRepository implements CalendarRepository {
  final bool _supportsNative;

  /// All arguments passed to [createEvent], in call order.
  final List<Map<String, Object?>> createEventCalls = [];

  /// IDs passed to [deleteEvent], in call order.
  final List<String> deletedEventIds = [];

  int _eventCounter = 0;

  FakeCalendarRepository({bool supportsNative = true})
      : _supportsNative = supportsNative;

  @override
  bool get supportsNativeCalendar => _supportsNative;

  @override
  Future<String?> createEvent({
    required String title,
    required DateTime date,
    required String notes,
    required int alarmMinutesBefore,
  }) async {
    final returnedId = 'cal-event-${++_eventCounter}';
    createEventCalls.add({
      'title': title,
      'date': date,
      'notes': notes,
      'alarmMinutesBefore': alarmMinutesBefore,
      'returnedId': returnedId,
    });
    return returnedId;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    deletedEventIds.add(eventId);
  }

  @override
  String exportIcs({
    required String title,
    required DateTime date,
    required String notes,
    required int alarmMinutesBefore,
  }) =>
      ''; // not under test here
}

/// In-memory [NotificationRepository] that records scheduling and cancellation
/// calls for later assertion.
class FakeNotificationRepository implements NotificationRepository {
  /// Notifications that were scheduled: maps notification id → scheduled date.
  final Map<int, DateTime> scheduledNotifications = {};

  /// IDs passed to [cancel], in call order.
  final List<int> cancelledIds = [];

  /// Set to true if [cancelAll] was invoked.
  bool cancelAllCalled = false;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<int> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    scheduledNotifications[id] = scheduledDate;
    return id;
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalled = true;
  }
}

/// In-memory [SyncedEventRepository].
///
/// Use [seed] to inject pre-existing records that [getForShot] will return,
/// simulating the state left by a previous sync run (the idempotent-delete
/// path in [SyncCalendarUseCase]).
class FakeSyncedEventRepository implements SyncedEventRepository {
  /// Per-vaccinationId store of seeded records.
  final Map<int, List<SyncedEventRecord>> _seeded = {};

  /// Records inserted via [insert], in call order.
  final List<SyncedEventRecord> inserted = [];

  /// Vaccination IDs for which [deleteForShot] was called, in call order.
  final List<int> deletedForShotIds = [];

  /// Injects pre-existing records for [vaccinationId] so the fake will return
  /// them from [getForShot].
  void seed(int vaccinationId, List<SyncedEventRecord> records) {
    _seeded[vaccinationId] = List.of(records);
  }

  @override
  Future<List<SyncedEventRecord>> getForShot(int vaccinationId) async =>
      List.of(_seeded[vaccinationId] ?? []);

  @override
  Future<List<SyncedEventRecord>> getForUser(int userId) async =>
      _seeded.values.expand((r) => r).toList();

  @override
  Future<void> insert(SyncedEventRecord record) async {
    inserted.add(record);
  }

  @override
  Future<void> deleteForShot(int vaccinationId) async {
    deletedForShotIds.add(vaccinationId);
    _seeded.remove(vaccinationId); // mirror real deletion so re-reads return []
  }

  @override
  Future<void> deleteAll(int userId) async {
    _seeded.clear();
  }
}

// =============================================================================
// Test-data helpers
// =============================================================================

/// A stable midnight-today anchor so relative dates never flip mid-test.
final _today = () {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}();

DateTime get _yesterday => _today.subtract(const Duration(days: 1));
DateTime get _in30Days => _today.add(const Duration(days: 30));

/// Builds a [VaccinationEntryEntity] with sensible defaults.
VaccinationEntryEntity _shot({
  int id = 1,
  int userId = 1,
  String name = 'Flu',
  int shotNumber = 1,
  int totalShots = 1,
  DateTime? vaccinationDate,
  DateTime? nextVaccinationDate,
}) =>
    VaccinationEntryEntity(
      id: id,
      userId: userId,
      name: name,
      shotNumber: shotNumber,
      totalShots: totalShots,
      vaccinationDate: vaccinationDate,
      nextVaccinationDate: nextVaccinationDate,
    );

/// Preferences with every integration point enabled and a 1-day advance window.
/// Using 1 day keeps notifyDate (= shotDate − 1 day) safely in the future for
/// any shot that is 30+ days away.
const _prefsAll = NotificationPreferenceEntity(
  notificationsEnabled: true,
  calendarSyncEnabled: true,
  reminderAdvanceDays: 1,
);

/// Preferences with every integration point explicitly disabled.
const _prefsNone = NotificationPreferenceEntity(
  notificationsEnabled: false,
  calendarSyncEnabled: false,
  reminderAdvanceDays: 7,
);

// =============================================================================
// Tests
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // ExportIcsUseCase
  // ---------------------------------------------------------------------------

  group('ExportIcsUseCase', () {
    // Pure-Dart use case; no fakes required.
    const useCase = ExportIcsUseCase();

    // ── Empty list ──────────────────────────────────────────────────────────

    test(
      'empty shots list → valid VCALENDAR wrapper present, no VEVENT emitted',
      () {
        // A calendar file with zero events must still be structurally valid
        // so importing apps do not reject it.
        final ics = useCase(shots: [], alarmMinutesBefore: 30);

        expect(ics, contains('BEGIN:VCALENDAR'));
        expect(ics, contains('END:VCALENDAR'));
        expect(ics, isNot(contains('BEGIN:VEVENT')));
        expect(ics, isNot(contains('END:VEVENT')));
      },
    );

    // ── Single shot with a past date ─────────────────────────────────────

    test(
      'single shot with a past date → contains one VEVENT with correct '
      'SUMMARY and UID',
      () {
        // Past shots must still be exportable (users may want historical
        // records in their calendar app).
        final shot = _shot(
          id: 42,
          userId: 7,
          name: 'Flu',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: _yesterday,
        );

        final ics = useCase(shots: [shot], alarmMinutesBefore: 30);

        expect(ics, contains('BEGIN:VEVENT'));
        expect(ics, contains('END:VEVENT'));
        // SUMMARY must carry the vaccine name
        expect(ics, contains('SUMMARY:💉 Flu'));
        // UID must embed both the userId and the shot's id so it is globally
        // unique and stable across re-exports
        expect(ics, contains('UID:vaccinecare-7-42-'));
      },
    );

    // ── Multi-shot series with a null-dated entry ────────────────────────

    test(
      'multi-shot series with one null-dated shot → one VEVENT per dated '
      'shot, null-dated shot is skipped',
      () {
        // Shot 2 has no date — it must not appear in the export.
        final shots = [
          _shot(id: 1, shotNumber: 1, totalShots: 3, vaccinationDate: _yesterday),
          _shot(id: 2, shotNumber: 2, totalShots: 3, vaccinationDate: null),
          _shot(id: 3, shotNumber: 3, totalShots: 3, vaccinationDate: _in30Days),
        ];

        final ics = useCase(shots: shots, alarmMinutesBefore: 15);

        final eventCount = 'BEGIN:VEVENT'.allMatches(ics).length;
        expect(
          eventCount,
          2,
          reason: 'null-dated shot must be omitted from the output',
        );
      },
    );

    // ── VALARM trigger ───────────────────────────────────────────────────

    test(
      'VALARM trigger reflects alarmMinutesBefore parameter',
      () {
        // RFC-5545 §3.8.6.3 — a 45-minute alarm must produce TRIGGER:-PT45M.
        final shot = _shot(id: 1, vaccinationDate: _in30Days);

        final ics = useCase(shots: [shot], alarmMinutesBefore: 45);

        expect(ics, contains('TRIGGER:-PT45M'));
      },
    );

    // ── Multi-shot SUMMARY label ─────────────────────────────────────────

    test(
      'totalShots > 1 → SUMMARY contains "Shot X of Y" position label',
      () {
        // The position within the series must be surfaced in the calendar
        // title so the user knows which dose they are being reminded about.
        final shot = _shot(
          id: 1,
          name: 'COVID-19',
          shotNumber: 2,
          totalShots: 3,
          vaccinationDate: _in30Days,
        );

        final ics = useCase(shots: [shot], alarmMinutesBefore: 60);

        expect(ics, contains('Shot 2 of 3'));
      },
    );

    // ── Single-shot SUMMARY label ────────────────────────────────────────

    test(
      'totalShots == 1 → SUMMARY does NOT contain "Shot" suffix',
      () {
        // A single-dose vaccine should not emit "Shot 1 of 1" — that label
        // is noise and degrades the calendar event title.
        final shot = _shot(
          id: 1,
          name: 'Flu',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: _in30Days,
        );

        final ics = useCase(shots: [shot], alarmMinutesBefore: 60);

        final summaryLine =
            ics.split('\n').firstWhere((l) => l.startsWith('SUMMARY:'));
        expect(summaryLine, isNot(contains('Shot')));
      },
    );

    // ── alarmMinutesBefore = 0 ───────────────────────────────────────────

    test(
      'alarmMinutesBefore=0 → TRIGGER:-PT0M (zero-minute alarm is valid RFC-5545)',
      () {
        final shot = _shot(id: 1, vaccinationDate: _in30Days);
        final ics = useCase(shots: [shot], alarmMinutesBefore: 0);
        expect(ics, contains('TRIGGER:-PT0M'));
      },
    );

    // ── nextVaccinationDate fallback ─────────────────────────────────────

    test(
      'shot with null vaccinationDate but set nextVaccinationDate → included '
      'in export using nextVaccinationDate as the event date',
      () {
        // A shot that has only a reminder date (no recorded date) must still
        // appear in the exported calendar so the user sees the upcoming event.
        final shot = _shot(
          id: 1,
          vaccinationDate: null,
          nextVaccinationDate: _in30Days,
        );
        final ics = useCase(shots: [shot], alarmMinutesBefore: 30);
        expect(ics, contains('BEGIN:VEVENT'));
        expect(ics, contains('END:VEVENT'));
      },
    );

    test(
      'shot with both vaccinationDate and nextVaccinationDate null → skipped',
      () {
        final shot = _shot(
          id: 1,
          vaccinationDate: null,
          nextVaccinationDate: null,
        );
        final ics = useCase(shots: [shot], alarmMinutesBefore: 30);
        expect(ics, isNot(contains('BEGIN:VEVENT')));
      },
    );

    // ── UID uniqueness ───────────────────────────────────────────────────

    test(
      'two shots in a series produce distinct UIDs',
      () {
        final shots = [
          _shot(id: 1, shotNumber: 1, totalShots: 2, vaccinationDate: _yesterday),
          _shot(id: 2, shotNumber: 2, totalShots: 2, vaccinationDate: _in30Days),
        ];
        final ics = useCase(shots: shots, alarmMinutesBefore: 30);

        final uids = RegExp(r'UID:([^\r\n]+)')
            .allMatches(ics)
            .map((m) => m.group(1))
            .toSet();
        expect(uids.length, 2, reason: 'Each shot must have a unique UID');
      },
    );
  });

  // ---------------------------------------------------------------------------
  // SyncCalendarUseCase
  // ---------------------------------------------------------------------------

  group('SyncCalendarUseCase', () {
    /// Convenience factory that wires up any combination of fakes.
    SyncCalendarUseCase _makeUseCase({
      FakeCalendarRepository? calendarRepo,
      FakeNotificationRepository? notificationRepo,
      FakeSyncedEventRepository? syncedEventRepo,
    }) =>
        SyncCalendarUseCase(
          calendarRepo: calendarRepo ?? FakeCalendarRepository(),
          notificationRepo: notificationRepo ?? FakeNotificationRepository(),
          syncedEventRepo: syncedEventRepo ?? FakeSyncedEventRepository(),
        );

    // ── Both integrations disabled ───────────────────────────────────────

    test(
      'calendarSyncEnabled=false AND notificationsEnabled=false → '
      'no createEvent / scheduleNotification calls, nothing inserted',
      () async {
        // When the user has disabled both integrations the use case must be a
        // complete no-op at the platform level — no calendar writes, no
        // notifications scheduled, no synced_event rows written.
        final cal = FakeCalendarRepository();
        final notif = FakeNotificationRepository();
        final synced = FakeSyncedEventRepository();

        await _makeUseCase(
          calendarRepo: cal,
          notificationRepo: notif,
          syncedEventRepo: synced,
        ).call(
          shots: [_shot(id: 1, vaccinationDate: _in30Days)],
          prefs: _prefsNone,
        );

        expect(cal.createEventCalls, isEmpty);
        expect(notif.scheduledNotifications, isEmpty);
        expect(synced.inserted, isEmpty);
      },
    );

    // ── Calendar sync enabled ────────────────────────────────────────────

    test(
      'calendarSyncEnabled=true → createEvent called for future-dated shots; '
      'past and null-dated shots are skipped; synced records inserted',
      () async {
        // Only shots strictly after now() carry a meaningful calendar event.
        // Past and unscheduled shots must be silently ignored.
        final cal = FakeCalendarRepository(supportsNative: true);
        final notif = FakeNotificationRepository();
        final synced = FakeSyncedEventRepository();

        const prefs = NotificationPreferenceEntity(
          notificationsEnabled: false,
          calendarSyncEnabled: true,
          reminderAdvanceDays: 1,
        );

        await _makeUseCase(
          calendarRepo: cal,
          notificationRepo: notif,
          syncedEventRepo: synced,
        ).call(
          shots: [
            _shot(id: 1, vaccinationDate: _in30Days),  // future → synced
            _shot(id: 2, vaccinationDate: _yesterday),  // past   → skipped
            _shot(id: 3, vaccinationDate: null),        // null   → skipped
          ],
          prefs: prefs,
        );

        // Exactly one calendar event created (for shot 1)
        expect(cal.createEventCalls, hasLength(1));
        // Exactly one DB record persisted
        expect(synced.inserted, hasLength(1));
        expect(synced.inserted.first.vaccinationId, 1);
      },
    );

    // ── Notification scheduling ──────────────────────────────────────────

    test(
      'notificationsEnabled=true → scheduleNotification called for each '
      'future shot whose notify date is also in the future',
      () async {
        // notifyDate = shotDate − reminderAdvanceDays.
        // With reminderAdvanceDays=1 and shots 30+ days away, notifyDate is
        // 29+ days from now — unambiguously in the future.
        final cal = FakeCalendarRepository();
        final notif = FakeNotificationRepository();
        final synced = FakeSyncedEventRepository();

        const prefs = NotificationPreferenceEntity(
          notificationsEnabled: true,
          calendarSyncEnabled: false,
          reminderAdvanceDays: 1,
        );

        await _makeUseCase(
          calendarRepo: cal,
          notificationRepo: notif,
          syncedEventRepo: synced,
        ).call(
          shots: [
            _shot(id: 10, shotNumber: 1, vaccinationDate: _in30Days),
            _shot(
              id: 11,
              shotNumber: 1,
              vaccinationDate: _in30Days.add(const Duration(days: 10)),
            ),
            _shot(id: 12, shotNumber: 1, vaccinationDate: _yesterday), // skipped
          ],
          prefs: prefs,
        );

        // Only the two future shots trigger scheduleNotification
        expect(notif.scheduledNotifications, hasLength(2));
      },
    );

    // ── Idempotency: stale records deleted before fresh ones created ─────

    test(
      'idempotent: stale calendar event and notification are deleted before '
      'fresh ones are created',
      () async {
        // Re-running sync must not create duplicate events. Stale records from
        // a previous run must be cleaned up (deleteEvent + cancel) before new
        // ones are written.
        final cal = FakeCalendarRepository(supportsNative: true);
        final notif = FakeNotificationRepository();
        final synced = FakeSyncedEventRepository();

        // Simulate state left by a previous sync run
        synced.seed(1, [
          SyncedEventRecord(
            userId: 1,
            vaccinationId: 1,
            calendarEventId: 'stale-cal-event',
            notificationId: 9001,
            syncedAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ]);

        await _makeUseCase(
          calendarRepo: cal,
          notificationRepo: notif,
          syncedEventRepo: synced,
        ).call(
          shots: [_shot(id: 1, vaccinationDate: _in30Days)],
          prefs: _prefsAll,
        );

        // Stale platform event was removed
        expect(cal.deletedEventIds, contains('stale-cal-event'));
        // Stale notification was cancelled
        expect(notif.cancelledIds, contains(9001));
        // DB row for shot 1 was deleted before the new one was written
        expect(synced.deletedForShotIds, contains(1));
        // A fresh record was then inserted
        expect(synced.inserted, hasLength(1));
      },
    );

    // ── supportsNativeCalendar guard ─────────────────────────────────────

    test(
      'supportsNativeCalendar=false → createEvent not called even when '
      'calendarSyncEnabled=true',
      () async {
        // The repository contract signals that the current platform cannot
        // write native calendar events.  The use case must respect this flag
        // and avoid a pointless (and potentially crashing) createEvent call.
        final cal = FakeCalendarRepository(supportsNative: false);
        final notif = FakeNotificationRepository();
        final synced = FakeSyncedEventRepository();

        const prefs = NotificationPreferenceEntity(
          notificationsEnabled: false,
          calendarSyncEnabled: true, // user wants it, but platform can't
          reminderAdvanceDays: 1,
        );

        await _makeUseCase(
          calendarRepo: cal,
          notificationRepo: notif,
          syncedEventRepo: synced,
        ).call(
          shots: [_shot(id: 1, vaccinationDate: _in30Days)],
          prefs: prefs,
        );

        expect(
          cal.createEventCalls,
          isEmpty,
          reason:
              'createEvent must not be called when supportsNativeCalendar=false',
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // CancelNotificationsUseCase
  // ---------------------------------------------------------------------------

  group('CancelNotificationsUseCase', () {
    /// Convenience factory.
    CancelNotificationsUseCase _makeUseCase({
      FakeCalendarRepository? calendarRepo,
      FakeNotificationRepository? notificationRepo,
      FakeSyncedEventRepository? syncedEventRepo,
    }) =>
        CancelNotificationsUseCase(
          calendarRepo: calendarRepo ?? FakeCalendarRepository(),
          notificationRepo: notificationRepo ?? FakeNotificationRepository(),
          syncedEventRepo: syncedEventRepo ?? FakeSyncedEventRepository(),
        );

    // ── Empty list ───────────────────────────────────────────────────────

    test(
      'empty list → no repo calls made at all',
      () async {
        // Calling with an empty id list must be a complete no-op — no platform
        // calls and no DB writes.
        final cal = FakeCalendarRepository();
        final notif = FakeNotificationRepository();
        final synced = FakeSyncedEventRepository();

        await _makeUseCase(
          calendarRepo: cal,
          notificationRepo: notif,
          syncedEventRepo: synced,
        ).callForShots([]);

        expect(cal.deletedEventIds, isEmpty);
        expect(notif.cancelledIds, isEmpty);
        expect(synced.deletedForShotIds, isEmpty);
      },
    );

    // ── Shot IDs with synced records ─────────────────────────────────────

    test(
      'shot IDs that have synced records → deleteEvent and cancel called per '
      'record; deleteForShot called for each ID',
      () async {
        // For each shot the use case must delete the calendar event, cancel
        // the notification, and remove the DB row — in that logical order.
        final cal = FakeCalendarRepository();
        final notif = FakeNotificationRepository();
        final synced = FakeSyncedEventRepository();

        synced.seed(10, [
          SyncedEventRecord(
            userId: 1,
            vaccinationId: 10,
            calendarEventId: 'evt-10',
            notificationId: 1010,
            syncedAt: DateTime.now(),
          ),
        ]);
        synced.seed(20, [
          SyncedEventRecord(
            userId: 1,
            vaccinationId: 20,
            calendarEventId: 'evt-20',
            notificationId: 2020,
            syncedAt: DateTime.now(),
          ),
        ]);

        await _makeUseCase(
          calendarRepo: cal,
          notificationRepo: notif,
          syncedEventRepo: synced,
        ).callForShots([10, 20]);

        // Calendar events removed for both shots
        expect(cal.deletedEventIds, containsAll(['evt-10', 'evt-20']));
        // Notifications cancelled for both shots
        expect(notif.cancelledIds, containsAll([1010, 2020]));
        // DB rows removed for both shot IDs
        expect(synced.deletedForShotIds, containsAll([10, 20]));
      },
    );

    // ── Shot IDs with no synced records ──────────────────────────────────

    test(
      'shot IDs with no synced records → no deleteEvent / cancel calls, '
      'completes without error',
      () async {
        // A shot that was never synced (e.g., created before sync was enabled,
        // or prefs were disabled) must be handled gracefully — no crash, no
        // spurious platform calls.
        final cal = FakeCalendarRepository();
        final notif = FakeNotificationRepository();
        final synced = FakeSyncedEventRepository();
        // Deliberately no seeds → getForShot returns [] for every id

        await expectLater(
          _makeUseCase(
            calendarRepo: cal,
            notificationRepo: notif,
            syncedEventRepo: synced,
          ).callForShots([99, 100]),
          completes,
        );

        expect(cal.deletedEventIds, isEmpty);
        expect(notif.cancelledIds, isEmpty);
        // deleteForShot is still called (idempotent cleanup of the DB table)
        expect(synced.deletedForShotIds, containsAll([99, 100]));
      },
    );
  });
}
