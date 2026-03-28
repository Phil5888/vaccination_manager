class SyncedEventRecord {
  final int? id;
  final int userId;
  final int vaccinationId;
  final String? calendarEventId;
  final int? notificationId;
  final DateTime syncedAt;

  const SyncedEventRecord({
    this.id,
    required this.userId,
    required this.vaccinationId,
    this.calendarEventId,
    this.notificationId,
    required this.syncedAt,
  });

  SyncedEventRecord copyWith({
    int? id,
    int? userId,
    int? vaccinationId,
    String? calendarEventId,
    bool clearCalendarEventId = false,
    int? notificationId,
    bool clearNotificationId = false,
    DateTime? syncedAt,
  }) {
    return SyncedEventRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vaccinationId: vaccinationId ?? this.vaccinationId,
      calendarEventId: clearCalendarEventId
          ? null
          : calendarEventId ?? this.calendarEventId,
      notificationId:
          clearNotificationId ? null : notificationId ?? this.notificationId,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
