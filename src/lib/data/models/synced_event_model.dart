import 'package:vaccination_manager/domain/entities/synced_event_record.dart';

class SyncedEventModel {
  final int? id;
  final int userId;
  final int vaccinationId;
  final String? calendarEventId;
  final int? notificationId;
  final DateTime syncedAt;

  const SyncedEventModel({
    this.id,
    required this.userId,
    required this.vaccinationId,
    this.calendarEventId,
    this.notificationId,
    required this.syncedAt,
  });

  factory SyncedEventModel.fromMap(Map<String, dynamic> map) {
    return SyncedEventModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      vaccinationId: map['vaccination_id'] as int,
      calendarEventId: map['calendar_event_id'] as String?,
      notificationId: map['notification_id'] as int?,
      syncedAt: DateTime.parse(map['synced_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'vaccination_id': vaccinationId,
      'calendar_event_id': calendarEventId,
      'notification_id': notificationId,
      'synced_at': syncedAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory SyncedEventModel.fromEntity(SyncedEventRecord entity) {
    return SyncedEventModel(
      id: entity.id,
      userId: entity.userId,
      vaccinationId: entity.vaccinationId,
      calendarEventId: entity.calendarEventId,
      notificationId: entity.notificationId,
      syncedAt: entity.syncedAt,
    );
  }

  SyncedEventRecord toEntity() {
    return SyncedEventRecord(
      id: id,
      userId: userId,
      vaccinationId: vaccinationId,
      calendarEventId: calendarEventId,
      notificationId: notificationId,
      syncedAt: syncedAt,
    );
  }
}
