import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_series_use_case.dart';

import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';

void main() {
  late GetVaccinationSeriesUseCase useCase;

  setUp(() {
    useCase = GetVaccinationSeriesUseCase(FakeVaccinationRepository());
  });

  group('fromEntries', () {
    test('empty input returns empty list', () {
      final result = useCase.fromEntries([]);
      expect(result, isEmpty);
    });

    test('single entry produces a single series with one shot', () {
      final entries = [Fixtures.singleShotPast()];
      final result = useCase.fromEntries(entries);
      expect(result, hasLength(1));
      expect(result.first.shots, hasLength(1));
      expect(result.first.name, 'Flu');
    });

    test('two entries with different vaccine names produce two separate series',
        () {
      final entries = [
        Fixtures.singleShotPast(name: 'Flu'),
        Fixtures.singleShotPast(name: 'MMR'),
      ];
      final result = useCase.fromEntries(entries);
      expect(result, hasLength(2));
      final names = result.map((s) => s.name).toList();
      expect(names, containsAll(['Flu', 'MMR']));
    });

    test('groups shots with same name case-insensitively', () {
      final entries = [
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 1,
          totalShots: 2,
          vaccinationDate: Fixtures.thirtyDaysAgo,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'covid-19',
          shotNumber: 2,
          totalShots: 2,
          vaccinationDate: Fixtures.yesterday,
        ),
      ];
      final result = useCase.fromEntries(entries);
      expect(result, hasLength(1));
      expect(result.first.shots, hasLength(2));
    });

    test('preserves original name casing from the first entry encountered', () {
      final entries = [
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 1,
          totalShots: 2,
          vaccinationDate: Fixtures.thirtyDaysAgo,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'covid-19',
          shotNumber: 2,
          totalShots: 2,
          vaccinationDate: Fixtures.yesterday,
        ),
      ];
      final result = useCase.fromEntries(entries);
      // The name of the first entry encountered ('COVID-19') should be preserved
      expect(result.first.name, 'COVID-19');
    });

    test('sorts shots within a series by shotNumber ASC regardless of input order',
        () {
      final entries = [
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 3,
          totalShots: 3,
          vaccinationDate: Fixtures.yesterday,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 1,
          totalShots: 3,
          vaccinationDate: Fixtures.thirtyDaysAgo,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 2,
          totalShots: 3,
          vaccinationDate: Fixtures.thirtyDaysAgo,
        ),
      ];
      final result = useCase.fromEntries(entries);
      final shotNumbers =
          result.first.shots.map((s) => s.shotNumber).toList();
      expect(shotNumbers, [1, 2, 3]);
    });

    test('returns series sorted alphabetically by name', () {
      final entries = [
        Fixtures.singleShotPast(name: 'Typhoid'),
        Fixtures.singleShotPast(name: 'Flu'),
        Fixtures.singleShotPast(name: 'MMR'),
      ];
      final result = useCase.fromEntries(entries);
      final names = result.map((s) => s.name).toList();
      expect(names, ['Flu', 'MMR', 'Typhoid']);
    });
  });
}
