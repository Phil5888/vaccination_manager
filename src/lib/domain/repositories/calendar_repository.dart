abstract class CalendarRepository {
  /// Returns true if the platform supports native calendar write with event IDs.
  bool get supportsNativeCalendar;

  /// Creates a calendar event. Returns the platform event ID (or null if not supported).
  Future<String?> createEvent({
    required String title,
    required DateTime date,
    required String notes,
    required int alarmMinutesBefore,
  });

  /// Deletes a previously created event by its platform ID. No-op if ID not found.
  Future<void> deleteEvent(String eventId);

  /// Generates an .ics string for the given event (fallback for all platforms).
  String exportIcs({
    required String title,
    required DateTime date,
    required String notes,
    required int alarmMinutesBefore,
  });
}
