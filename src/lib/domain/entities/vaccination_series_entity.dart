import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

/// A vaccination series groups all [VaccinationEntryEntity] records that share
/// the same lowercased vaccine name. This entity is computed in-memory and is
/// never persisted to the database.
class VaccinationSeriesEntity {
  final String name; // display name (original casing from first entry)
  final List<VaccinationEntryEntity> shots; // sorted by vaccinationDate ASC

  const VaccinationSeriesEntity({required this.name, required this.shots});

  /// The most recent shot.
  VaccinationEntryEntity get latestShot => shots.last;

  /// The next vaccination date from the latest shot (may be null).
  DateTime? get nextVaccinationDate => latestShot.nextVaccinationDate;

  bool get isMultiShot => shots.length > 1;
}
