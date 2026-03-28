import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/repositories/vaccination_repository_impl.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/delete_vaccination_series_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/delete_vaccination_shot_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_reminders_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_series_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccinations_for_user_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/save_vaccination_series_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/save_vaccination_use_case.dart';

final vaccinationRepositoryProvider = Provider<VaccinationRepository>((ref) {
  return VaccinationRepositoryImpl();
});

final getVaccinationsForUserUseCaseProvider =
    Provider<GetVaccinationsForUserUseCase>((ref) {
  return GetVaccinationsForUserUseCase(
      ref.watch(vaccinationRepositoryProvider));
});

final saveVaccinationUseCaseProvider = Provider<SaveVaccinationUseCase>((ref) {
  return SaveVaccinationUseCase(ref.watch(vaccinationRepositoryProvider));
});

final saveVaccinationSeriesUseCaseProvider =
    Provider<SaveVaccinationSeriesUseCase>((ref) {
  return SaveVaccinationSeriesUseCase(
      ref.watch(vaccinationRepositoryProvider));
});

final deleteVaccinationShotUseCaseProvider =
    Provider<DeleteVaccinationShotUseCase>((ref) {
  return DeleteVaccinationShotUseCase(ref.watch(vaccinationRepositoryProvider));
});

final deleteVaccinationSeriesUseCaseProvider =
    Provider<DeleteVaccinationSeriesUseCase>((ref) {
  return DeleteVaccinationSeriesUseCase(
      ref.watch(vaccinationRepositoryProvider));
});

final getVaccinationSeriesUseCaseProvider =
    Provider<GetVaccinationSeriesUseCase>((ref) {
  return GetVaccinationSeriesUseCase(ref.watch(vaccinationRepositoryProvider));
});

final getVaccinationRemindersUseCaseProvider =
    Provider<GetVaccinationRemindersUseCase>((ref) {
  return GetVaccinationRemindersUseCase(
      ref.watch(getVaccinationSeriesUseCaseProvider));
});
