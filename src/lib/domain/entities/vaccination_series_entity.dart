import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_status.dart';

/// A vaccination series groups all [VaccinationEntryEntity] records that share
/// the same lowercased vaccine name. This entity is computed in-memory and is
/// never persisted to the database.
class VaccinationSeriesEntity {
  final String name; // display name (original casing from first entry)
  final int userId;
  final List<VaccinationEntryEntity> shots; // sorted by shot_number ASC

  const VaccinationSeriesEntity({
    required this.name,
    required this.userId,
    required this.shots,
  });

  // ---------------------------------------------------------------------------
  // Core computed properties
  // ---------------------------------------------------------------------------

  int get totalShots => shots.isNotEmpty ? shots.first.totalShots : 0;

  int get completedShots {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return shots
        .where((s) =>
            s.vaccinationDate != null &&
            !s.vaccinationDate!.isAfter(today))
        .length;
  }

  double get progressPercentage =>
      totalShots > 0 ? completedShots / totalShots : 0.0;

  bool get isComplete => totalShots > 0 && completedShots >= totalShots;

  /// Earliest future-dated or unscheduled (null-date) shot.
  DateTime? get nextActionDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final shot in shots) {
      if (shot.vaccinationDate == null) return null;
      if (shot.vaccinationDate!.isAfter(today)) return shot.vaccinationDate;
    }
    return null;
  }

  VaccinationSeriesStatus get seriesStatus {
    if (isComplete) {
      // For single-shot series: check if next_vaccination_date has passed
      if (totalShots == 1 && shots.isNotEmpty) {
        final next = shots.first.nextVaccinationDate;
        if (next != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          if (next.isBefore(today)) return VaccinationSeriesStatus.overdue;
        }
      }
      return VaccinationSeriesStatus.complete;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Remaining = shots with null date or a future date
    final remainingShots = shots
        .where((s) =>
            s.vaccinationDate == null || s.vaccinationDate!.isAfter(today))
        .toList();

    if (remainingShots.isEmpty) {
      // All shots have past dates → isComplete should have caught this,
      // but guard against totalShots mismatch.
      return VaccinationSeriesStatus.inProgress;
    }

    if (completedShots == 0) {
      // No shots completed yet → planned
      return VaccinationSeriesStatus.planned;
    }

    // Some shots done, some remaining → in progress
    return VaccinationSeriesStatus.inProgress;
  }

  // ---------------------------------------------------------------------------
  // Backward-compatible getters (used by existing screens)
  // ---------------------------------------------------------------------------

  /// The last shot in the sorted list (highest shot_number).
  VaccinationEntryEntity get latestShot => shots.last;

  /// Next vaccination date from the latest shot (single-shot reminder compat).
  DateTime? get nextVaccinationDate => latestShot.nextVaccinationDate;

  bool get isMultiShot => shots.length > 1;
}
