import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

class VaccinationModel {
  final int? id;
  final int userId;
  final String name;
  final int shotNumber;
  final int totalShots;
  final DateTime? vaccinationDate;
  final DateTime? nextVaccinationDate;

  const VaccinationModel({
    this.id,
    required this.userId,
    required this.name,
    this.shotNumber = 1,
    this.totalShots = 1,
    this.vaccinationDate,
    this.nextVaccinationDate,
  });

  factory VaccinationModel.fromMap(Map<String, dynamic> map) {
    return VaccinationModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      shotNumber: (map['shot_number'] as int?) ?? 1,
      totalShots: (map['total_shots'] as int?) ?? 1,
      vaccinationDate: map['vaccination_date'] != null
          ? DateTime.parse(map['vaccination_date'] as String)
          : null,
      nextVaccinationDate: map['next_vaccination_date'] != null
          ? DateTime.parse(map['next_vaccination_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'shot_number': shotNumber,
      'total_shots': totalShots,
      'vaccination_date':
          vaccinationDate?.toIso8601String().split('T').first,
      'next_vaccination_date':
          nextVaccinationDate?.toIso8601String().split('T').first,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory VaccinationModel.fromEntity(VaccinationEntryEntity entity) {
    return VaccinationModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      shotNumber: entity.shotNumber,
      totalShots: entity.totalShots,
      vaccinationDate: entity.vaccinationDate,
      nextVaccinationDate: entity.nextVaccinationDate,
    );
  }

  VaccinationEntryEntity toEntity() {
    return VaccinationEntryEntity(
      id: id,
      userId: userId,
      name: name,
      shotNumber: shotNumber,
      totalShots: totalShots,
      vaccinationDate: vaccinationDate,
      nextVaccinationDate: nextVaccinationDate,
    );
  }
}
