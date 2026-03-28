class NotificationPreferenceEntity {
  final bool notificationsEnabled;
  final bool calendarSyncEnabled;
  final int reminderAdvanceDays;
  final int notificationHour;
  final int notificationMinute;

  const NotificationPreferenceEntity({
    this.notificationsEnabled = true,
    this.calendarSyncEnabled = false,
    this.reminderAdvanceDays = 7,
    this.notificationHour = 9,
    this.notificationMinute = 0,
  });

  NotificationPreferenceEntity copyWith({
    bool? notificationsEnabled,
    bool? calendarSyncEnabled,
    int? reminderAdvanceDays,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return NotificationPreferenceEntity(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      calendarSyncEnabled: calendarSyncEnabled ?? this.calendarSyncEnabled,
      reminderAdvanceDays: reminderAdvanceDays ?? this.reminderAdvanceDays,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }
}
