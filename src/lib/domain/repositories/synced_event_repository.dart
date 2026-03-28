import 'package:vaccination_manager/domain/entities/synced_event_record.dart';

abstract class SyncedEventRepository {
  Future<List<SyncedEventRecord>> getForShot(int vaccinationId);
  Future<List<SyncedEventRecord>> getForUser(int userId);
  Future<void> insert(SyncedEventRecord record);
  Future<void> deleteForShot(int vaccinationId);
  Future<void> deleteAll(int userId);
}
