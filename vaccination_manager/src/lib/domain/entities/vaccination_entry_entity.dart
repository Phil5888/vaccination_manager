class VaccinationEntryEntity {
  const VaccinationEntryEntity({required this.id, required this.userId, required this.name, required this.vaccinationDate, required this.nextVaccinationRequiredDate, required this.createdAt});

  final int? id;
  final int userId;
  final String name;
  final DateTime vaccinationDate;
  final DateTime nextVaccinationRequiredDate;
  final DateTime createdAt;

  VaccinationEntryEntity copyWith({int? id, int? userId, String? name, DateTime? vaccinationDate, DateTime? nextVaccinationRequiredDate, DateTime? createdAt}) {
    return VaccinationEntryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      vaccinationDate: vaccinationDate ?? this.vaccinationDate,
      nextVaccinationRequiredDate: nextVaccinationRequiredDate ?? this.nextVaccinationRequiredDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
