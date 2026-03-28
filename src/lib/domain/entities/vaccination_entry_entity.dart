class VaccinationEntryEntity {
  final int? id;
  final int userId;
  final String name;
  final DateTime vaccinationDate;
  final DateTime? nextVaccinationDate;

  const VaccinationEntryEntity({
    this.id,
    required this.userId,
    required this.name,
    required this.vaccinationDate,
    this.nextVaccinationDate,
  });

  VaccinationEntryEntity copyWith({
    int? id,
    int? userId,
    String? name,
    DateTime? vaccinationDate,
    DateTime? nextVaccinationDate,
    bool clearNextVaccinationDate = false,
  }) {
    return VaccinationEntryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      vaccinationDate: vaccinationDate ?? this.vaccinationDate,
      nextVaccinationDate: clearNextVaccinationDate
          ? null
          : nextVaccinationDate ?? this.nextVaccinationDate,
    );
  }
}
