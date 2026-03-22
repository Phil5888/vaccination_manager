import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/data/repositories/vaccination_repository_impl.dart';
import 'package:vaccination_manager/domain/usecases/delete_vaccination_usecase.dart';
import 'package:vaccination_manager/domain/usecases/get_vaccinations_for_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_vaccination_usecase.dart';

final vaccinationRepositoryProvider = Provider<VaccinationRepositoryImpl>((ref) {
  return VaccinationRepositoryImpl(database: AppDatabase.instance);
});

final getVaccinationsForUserUseCaseProvider = Provider<GetVaccinationsForUserUseCase>((ref) {
  return GetVaccinationsForUserUseCase(ref.read(vaccinationRepositoryProvider));
});

final saveVaccinationUseCaseProvider = Provider<SaveVaccinationUseCase>((ref) {
  return SaveVaccinationUseCase(ref.read(vaccinationRepositoryProvider));
});

final deleteVaccinationUseCaseProvider = Provider<DeleteVaccinationUseCase>((ref) {
  return DeleteVaccinationUseCase(ref.read(vaccinationRepositoryProvider));
});
