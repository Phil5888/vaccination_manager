import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/usecases/delete_vaccination_usecase.dart';
import 'package:vaccination_manager/domain/usecases/get_vaccinations_for_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_vaccination_usecase.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_dependency_providers.dart';

enum VaccinationReminderFilter { all, overdue, dueSoon, upToDate }

class VaccinationOverviewState {
  const VaccinationOverviewState({required this.activeUser, required this.series, this.selectedFilter = VaccinationReminderFilter.all});

  final AppUserEntity? activeUser;
  final List<VaccinationSeriesEntity> series;
  final VaccinationReminderFilter selectedFilter;

  bool get hasActiveUser => activeUser != null;
  bool get hasVaccinations => series.isNotEmpty;

  VaccinationOverviewState copyWith({AppUserEntity? activeUser, List<VaccinationSeriesEntity>? series, VaccinationReminderFilter? selectedFilter}) {
    return VaccinationOverviewState(activeUser: activeUser ?? this.activeUser, series: series ?? this.series, selectedFilter: selectedFilter ?? this.selectedFilter);
  }

  List<VaccinationSeriesEntity> filteredSeriesAt(DateTime referenceDate) {
    if (selectedFilter == VaccinationReminderFilter.all) {
      return series;
    }

    return series.where((item) {
      final status = item.statusAt(referenceDate);
      switch (selectedFilter) {
        case VaccinationReminderFilter.all:
          return true;
        case VaccinationReminderFilter.overdue:
          return status == VaccinationDueStatus.overdue;
        case VaccinationReminderFilter.dueSoon:
          return status == VaccinationDueStatus.dueSoon;
        case VaccinationReminderFilter.upToDate:
          return status == VaccinationDueStatus.upToDate;
      }
    }).toList();
  }

  int overdueCountAt(DateTime referenceDate) {
    return series.where((item) => item.statusAt(referenceDate) == VaccinationDueStatus.overdue).length;
  }

  int dueSoonCountAt(DateTime referenceDate) {
    return series.where((item) => item.statusAt(referenceDate) == VaccinationDueStatus.dueSoon).length;
  }

  VaccinationSeriesEntity? nextDueSeriesAt(DateTime referenceDate) {
    if (series.isEmpty) {
      return null;
    }

    final sorted = List<VaccinationSeriesEntity>.from(series);
    sorted.sort((a, b) {
      final statusWeight = _statusWeight(a.statusAt(referenceDate)).compareTo(_statusWeight(b.statusAt(referenceDate)));
      if (statusWeight != 0) {
        return statusWeight;
      }
      return a.nextRequiredDate.compareTo(b.nextRequiredDate);
    });
    return sorted.first;
  }

  int _statusWeight(VaccinationDueStatus status) {
    switch (status) {
      case VaccinationDueStatus.overdue:
        return 0;
      case VaccinationDueStatus.dueSoon:
        return 1;
      case VaccinationDueStatus.upToDate:
        return 2;
    }
  }
}

class VaccinationViewModel extends AsyncNotifier<VaccinationOverviewState> {
  late final GetVaccinationsForUserUseCase _getVaccinationsForUser;
  late final SaveVaccinationUseCase _saveVaccination;
  late final DeleteVaccinationUseCase _deleteVaccination;

  @override
  Future<VaccinationOverviewState> build() async {
    _getVaccinationsForUser = ref.read(getVaccinationsForUserUseCaseProvider);
    _saveVaccination = ref.read(saveVaccinationUseCaseProvider);
    _deleteVaccination = ref.read(deleteVaccinationUseCaseProvider);
    final userState = await ref.watch(userManagementProvider.future);
    return _loadState(userState.activeUser);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final userState = await ref.read(userManagementProvider.future);
    state = await AsyncValue.guard(() => _loadState(userState.activeUser));
  }

  void setFilter(VaccinationReminderFilter filter) {
    final currentState = state.asData?.value;
    if (currentState == null || currentState.selectedFilter == filter) {
      return;
    }

    state = AsyncData(currentState.copyWith(selectedFilter: filter));
  }

  Future<VaccinationEntryEntity> saveVaccination({int? id, String? name, required DateTime vaccinationDate, required DateTime nextVaccinationRequiredDate}) async {
    final currentState = state.asData?.value ?? await build();
    final activeUser = currentState.activeUser;
    if (activeUser?.id == null) {
      throw StateError('An active user is required to save vaccinations.');
    }

    final existing = _findEntryById(currentState.series, id);
    final saved = await _saveVaccination(
      VaccinationEntryEntity(
        id: id,
        userId: activeUser!.id!,
        name: (name ?? existing?.name ?? '').trim(),
        vaccinationDate: vaccinationDate,
        nextVaccinationRequiredDate: nextVaccinationRequiredDate,
        createdAt: existing?.createdAt ?? DateTime.now(),
      ),
    );

    await refresh();
    return saved;
  }

  Future<void> deleteVaccination(int vaccinationId) async {
    final currentState = state.asData?.value ?? await build();
    if (!currentState.hasActiveUser) {
      throw StateError('An active user is required to delete vaccinations.');
    }

    await _deleteVaccination(vaccinationId);
    await refresh();
  }

  Future<VaccinationOverviewState> _loadState(AppUserEntity? activeUser) async {
    if (activeUser?.id == null) {
      return const VaccinationOverviewState(activeUser: null, series: []);
    }

    final entries = await _getVaccinationsForUser(activeUser!.id!);
    final grouped = <String, List<VaccinationEntryEntity>>{};
    for (final entry in entries) {
      final key = entry.name.trim().toLowerCase();
      grouped.putIfAbsent(key, () => <VaccinationEntryEntity>[]).add(entry);
    }

    final series = grouped.values.map((items) => VaccinationSeriesEntity(name: items.first.name.trim(), entries: items)).toList()
      ..sort((a, b) {
        final now = DateTime.now();
        final statusWeight = _statusWeight(a.statusAt(now)).compareTo(_statusWeight(b.statusAt(now)));
        if (statusWeight != 0) {
          return statusWeight;
        }
        return a.nextRequiredDate.compareTo(b.nextRequiredDate);
      });

    final currentFilter = state.asData?.value.selectedFilter ?? VaccinationReminderFilter.all;
    return VaccinationOverviewState(activeUser: activeUser, series: series, selectedFilter: currentFilter);
  }

  VaccinationEntryEntity? _findEntryById(List<VaccinationSeriesEntity> series, int? id) {
    if (id == null) {
      return null;
    }

    for (final item in series) {
      for (final entry in item.entries) {
        if (entry.id == id) {
          return entry;
        }
      }
    }

    return null;
  }

  int _statusWeight(VaccinationDueStatus status) {
    switch (status) {
      case VaccinationDueStatus.overdue:
        return 0;
      case VaccinationDueStatus.dueSoon:
        return 1;
      case VaccinationDueStatus.upToDate:
        return 2;
    }
  }
}
