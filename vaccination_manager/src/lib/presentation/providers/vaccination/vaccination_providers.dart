import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';

final vaccinationsProvider = AsyncNotifierProvider<VaccinationViewModel, VaccinationOverviewState>(VaccinationViewModel.new);
