// Tests for LocalNotificationRepositoryImpl — the real implementation that
// wraps FlutterLocalNotificationsPlugin.
//
// Injection strategy
// ------------------
// FlutterLocalNotificationsPlugin is a singleton (private constructor + static
// _instance), so it cannot be replaced by simply passing a different object.
// The real seam is FlutterLocalNotificationsPlatform.instance — the abstract
// platform interface that the plugin delegates to for every operation.
//
// We extend MacOSFlutterLocalNotificationsPlugin (which passes the
// PlatformInterface token-verification check through its constructor chain)
// and set debugDefaultTargetPlatformOverride = TargetPlatform.macOS so that:
//   • initialize  → resolvePlatformSpecificImplementation<Macos…>() → fake ✓
//   • zonedSchedule → resolvePlatformSpecificImplementation<Macos…>() → fake ✓
//   • cancel      → FlutterLocalNotificationsPlatform.instance.cancel() → fake ✓
//   • cancelAll   → FlutterLocalNotificationsPlatform.instance.cancelAll() → fake ✓
//
// No third-party mock library is used — hand-written fakes match the style of
// the rest of the test suite.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:vaccination_manager/data/repositories/local_notification_repository_impl.dart';

// =============================================================================
// Fake platform implementation
// =============================================================================

/// A test double for the macOS notification platform.
///
/// Extends [MacOSFlutterLocalNotificationsPlugin] so that:
///   1. The PlatformInterface token is set correctly by the super-constructor
///      chain, allowing [FlutterLocalNotificationsPlatform.instance] to be set
///      to this fake without an [AssertionError].
///   2. [FlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation]
///      returns this fake when the type argument is
///      [MacOSFlutterLocalNotificationsPlugin].
///
/// All methods that would otherwise invoke a platform channel are overridden to
/// record calls and return immediately.
class _FakeMacOSPlugin extends MacOSFlutterLocalNotificationsPlugin {
  /// Number of times [initialize] was called.
  int initializeCallCount = 0;

  /// Arguments passed to [zonedSchedule], in call order.
  final List<({int id, String? title, String? body, tz.TZDateTime scheduledDate})>
      zonedScheduleCalls = [];

  /// IDs passed to [cancel], in call order.
  final List<int> cancelCalls = [];

  /// Whether [cancelAll] was called.
  bool cancelAllCalled = false;

  @override
  Future<bool?> initialize(
    DarwinInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    initializeCallCount++;
    return true;
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    DarwinNotificationDetails? notificationDetails, {
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    zonedScheduleCalls.add((
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    ));
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalls.add(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalled = true;
  }
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  late _FakeMacOSPlugin fakePlatform;

  setUpAll(() {
    // TZDateTime.from(date, tz.local) requires timezone data to be loaded and
    // the `local` location to be set.  initializeTimeZones() loads all data and
    // sets `local` to UTC, which is sufficient for unit tests.
    tz_data.initializeTimeZones();
  });

  setUp(() {
    // Force the Flutter plugin to believe we are on macOS so all delegation
    // routes hit the fake rather than real platform channels.
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    fakePlatform = _FakeMacOSPlugin();
    FlutterLocalNotificationsPlatform.instance = fakePlatform;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('LocalNotificationRepositoryImpl', () {
    // -------------------------------------------------------------------------
    // scheduleNotification
    // -------------------------------------------------------------------------

    test(
        'scheduleNotification calls zonedSchedule with correct id, title, body '
        'and a TZDateTime matching the input date', () async {
      final repo =
          LocalNotificationRepositoryImpl.withPlugin(FlutterLocalNotificationsPlugin());
      // Use DateTime.utc so that tz.TZDateTime.from(date, UTC) is an
      // identity conversion regardless of the host machine's system timezone.
      final inputDate = DateTime.utc(2025, 8, 20, 9, 30, 0);

      final returnedId = await repo.scheduleNotification(
        id: 42,
        title: 'MMR booster',
        body: 'Time for your vaccination reminder',
        scheduledDate: inputDate,
      );

      expect(returnedId, equals(42),
          reason: 'scheduleNotification must return the provided id');

      expect(fakePlatform.zonedScheduleCalls, hasLength(1));
      final call = fakePlatform.zonedScheduleCalls.first;
      expect(call.id, equals(42));
      expect(call.title, equals('MMR booster'));
      expect(call.body, equals('Time for your vaccination reminder'));

      // The impl converts via tz.TZDateTime.from(date, tz.local).
      // Verify the resulting TZDateTime represents the same instant in time.
      expect(
        call.scheduledDate.millisecondsSinceEpoch,
        equals(inputDate.millisecondsSinceEpoch),
        reason: 'TZDateTime must represent the same instant as the input date',
      );
    });

    test('scheduleNotification returns the provided id', () async {
      final repo =
          LocalNotificationRepositoryImpl.withPlugin(FlutterLocalNotificationsPlugin());

      final result = await repo.scheduleNotification(
        id: 7,
        title: 'Flu shot',
        body: 'Annual flu vaccination due',
        scheduledDate: DateTime(2025, 12, 1),
      );

      expect(result, equals(7));
    });

    test(
        'scheduleNotification initialises the plugin exactly once even when '
        'called multiple times', () async {
      final repo =
          LocalNotificationRepositoryImpl.withPlugin(FlutterLocalNotificationsPlugin());
      final date = DateTime(2025, 9, 1);

      await repo.scheduleNotification(
          id: 1, title: 'A', body: 'B', scheduledDate: date);
      await repo.scheduleNotification(
          id: 2, title: 'C', body: 'D', scheduledDate: date);

      expect(fakePlatform.initializeCallCount, equals(1),
          reason: '_initialize() must be guarded by the _initialized flag');
    });

    // -------------------------------------------------------------------------
    // cancel
    // -------------------------------------------------------------------------

    test('cancel forwards the correct id to the underlying plugin', () async {
      final repo =
          LocalNotificationRepositoryImpl.withPlugin(FlutterLocalNotificationsPlugin());

      await repo.cancel(42);

      expect(fakePlatform.cancelCalls, equals([42]));
    });

    test('cancel initialises the plugin on a fresh instance', () async {
      final repo =
          LocalNotificationRepositoryImpl.withPlugin(FlutterLocalNotificationsPlugin());

      await repo.cancel(1);

      expect(fakePlatform.initializeCallCount, equals(1));
    });

    // -------------------------------------------------------------------------
    // cancelAll
    // -------------------------------------------------------------------------

    test('cancelAll calls plugin.cancelAll()', () async {
      final repo =
          LocalNotificationRepositoryImpl.withPlugin(FlutterLocalNotificationsPlugin());

      await repo.cancelAll();

      expect(fakePlatform.cancelAllCalled, isTrue);
    });
  });
}
