import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

class VaccinationModel {
  const VaccinationModel({required this.id, required this.userId, required this.name, required this.vaccinationDate, required this.nextVaccinationRequiredDate, required this.createdAt});

  final int? id;
  final int userId;
  final String name;
  final DateTime vaccinationDate;
  final DateTime nextVaccinationRequiredDate;
  final DateTime createdAt;

  factory VaccinationModel.fromMap(Map<String, Object?> map) {
    return VaccinationModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['vaccination_name'] as String,
      vaccinationDate: DateTime.parse(map['vaccination_date'] as String),
      nextVaccinationRequiredDate: DateTime.parse(map['next_vaccination_required_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  factory VaccinationModel.fromEntity(VaccinationEntryEntity entry) {
    return VaccinationModel(id: entry.id, userId: entry.userId, name: entry.name, vaccinationDate: entry.vaccinationDate, nextVaccinationRequiredDate: entry.nextVaccinationRequiredDate, createdAt: entry.createdAt);
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'vaccination_name': name,
      'vaccination_date': vaccinationDate.toIso8601String(),
      'next_vaccination_required_date': nextVaccinationRequiredDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  VaccinationEntryEntity toEntity() {
    return VaccinationEntryEntity(id: id, userId: userId, name: name, vaccinationDate: vaccinationDate, nextVaccinationRequiredDate: nextVaccinationRequiredDate, createdAt: createdAt);
  }
}
