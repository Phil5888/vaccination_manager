class VaccinationEntryEntity {
  final int? id;
  final int userId;
  final String name;
  final int shotNumber;
  final int totalShots;
  final DateTime? vaccinationDate;
  final DateTime? nextVaccinationDate;

  const VaccinationEntryEntity({
    this.id,
    required this.userId,
    required this.name,
    this.shotNumber = 1,
    this.totalShots = 1,
    this.vaccinationDate,
    this.nextVaccinationDate,
  });

  VaccinationEntryEntity copyWith({
    int? id,
    int? userId,
    String? name,
    int? shotNumber,
    int? totalShots,
    DateTime? vaccinationDate,
    bool clearVaccinationDate = false,
    DateTime? nextVaccinationDate,
    bool clearNextVaccinationDate = false,
  }) {
    return VaccinationEntryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      shotNumber: shotNumber ?? this.shotNumber,
      totalShots: totalShots ?? this.totalShots,
      vaccinationDate: clearVaccinationDate
          ? null
          : vaccinationDate ?? this.vaccinationDate,
      nextVaccinationDate: clearNextVaccinationDate
          ? null
          : nextVaccinationDate ?? this.nextVaccinationDate,
    );
  }
}
