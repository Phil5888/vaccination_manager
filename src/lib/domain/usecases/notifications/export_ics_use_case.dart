import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

/// Generates a valid RFC-5545 .ics string for a list of shots.
/// Pure Dart — no platform dependencies.
class ExportIcsUseCase {
  const ExportIcsUseCase();

  String call({
    required List<VaccinationEntryEntity> shots,
    required int alarmMinutesBefore,
  }) {
    final sb = StringBuffer();
    sb.writeln('BEGIN:VCALENDAR');
    sb.writeln('VERSION:2.0');
    sb.writeln('PRODID:-//VaccineCare//EN');
    sb.writeln('CALSCALE:GREGORIAN');
    sb.writeln('METHOD:PUBLISH');

    for (final shot in shots) {
      final date = shot.vaccinationDate ?? shot.nextVaccinationDate;
      if (date == null) continue;
      final title =
          '💉 ${shot.name}${shot.totalShots > 1 ? ' — Shot ${shot.shotNumber} of ${shot.totalShots}' : ''}';
      final uid =
          'vaccinecare-${shot.userId}-${shot.id ?? shot.shotNumber}-${shot.name.hashCode}@vaccinecare';
      final dtStamp = _formatDate(DateTime.now().toUtc());
      final dtStart = _formatDate(date.toUtc());

      sb.writeln('BEGIN:VEVENT');
      sb.writeln('UID:$uid');
      sb.writeln('DTSTAMP:$dtStamp');
      sb.writeln('DTSTART;VALUE=DATE:${dtStart.substring(0, 8)}');
      sb.writeln('SUMMARY:$title');
      sb.writeln(
          'DESCRIPTION:VaccineCare reminder — open app to record this vaccination.');
      sb.writeln('BEGIN:VALARM');
      sb.writeln('TRIGGER:-PT${alarmMinutesBefore}M');
      sb.writeln('ACTION:DISPLAY');
      sb.writeln('DESCRIPTION:Vaccination reminder');
      sb.writeln('END:VALARM');
      sb.writeln('END:VEVENT');
    }

    sb.writeln('END:VCALENDAR');
    return sb.toString();
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}'
        'T${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}Z';
  }
}
