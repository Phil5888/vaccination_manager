enum ReminderLeadTime {
  threeDays(3, '3d'),
  oneWeek(7, '1w'),
  twoWeeks(14, '2w'),
  oneMonth(30, '1m'),
  twoMonths(60, '2m'),
  threeMonths(90, '3m');

  const ReminderLeadTime(this.days, this.storageKey);

  final int days;
  final String storageKey;

  static ReminderLeadTime fromStorageKey(String? key) {
    for (final value in ReminderLeadTime.values) {
      if (value.storageKey == key) {
        return value;
      }
    }
    return ReminderLeadTime.oneWeek;
  }
}
