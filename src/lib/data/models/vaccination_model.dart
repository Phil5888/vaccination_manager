import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

class VaccinationModel {
  final int? id;
  final int userId;
  final String name;
  final DateTime vaccinationDate;
  final DateTime? nextVaccinationDate;

  const VaccinationModel({
    this.id,
    required this.userId,
    required this.name,
    required this.vaccinationDate,
    this.nextVaccinationDate,
  });

  factory VaccinationModel.fromMap(Map<String, dynamic> map) {
    return VaccinationModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      vaccinationDate: DateTime.parse(map['vaccination_date'] as String),
      nextVaccinationDate: map['next_vaccination_date'] != null
          ? DateTime.parse(map['next_vaccination_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'vaccination_date': vaccinationDate.toIso8601String().split('T').first,
      'next_vaccination_date': nextVaccinationDate
          ?.toIso8601String()
          .split('T')
          .first,
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
      vaccinationDate: entity.vaccinationDate,
      nextVaccinationDate: entity.nextVaccinationDate,
    );
  }

  VaccinationEntryEntity toEntity() {
    return VaccinationEntryEntity(
      id: id,
      userId: userId,
      name: name,
      vaccinationDate: vaccinationDate,
      nextVaccinationDate: nextVaccinationDate,
    );
  }
}
