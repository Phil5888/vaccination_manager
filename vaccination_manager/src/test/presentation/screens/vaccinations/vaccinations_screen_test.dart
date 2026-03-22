import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccinations_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';

class _TestVaccinationViewModel extends VaccinationViewModel {
  _TestVaccinationViewModel(this.initialState);

  final VaccinationOverviewState initialState;

  @override
  Future<VaccinationOverviewState> build() async => initialState;
}

void main() {
  final activeUser = AppUserEntity(id: 1, username: 'Alice', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));

  testWidgets('shows empty state when the active user has no vaccinations', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        viewModelFactory: () => _TestVaccinationViewModel(VaccinationOverviewState(activeUser: activeUser, series: const [])),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No vaccination records yet'), findsOneWidget);
    expect(find.text('Add vaccination'), findsWidgets);
  });

  testWidgets('shows grouped series details for multiple shots', (tester) async {
    final series = VaccinationSeriesEntity(
      name: 'COVID-19',
      entries: [
        VaccinationEntryEntity(id: 1, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 3, 10), nextVaccinationRequiredDate: DateTime(2026, 9, 10), createdAt: DateTime(2026, 3, 10)),
        VaccinationEntryEntity(id: 2, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 1, 10), nextVaccinationRequiredDate: DateTime(2026, 7, 10), createdAt: DateTime(2026, 1, 10)),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(
        viewModelFactory: () => _TestVaccinationViewModel(VaccinationOverviewState(activeUser: activeUser, series: [series])),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('COVID-19'), findsWidgets);
    await tester.tap(find.text('COVID-19').last);
    await tester.pumpAndSettle();

    expect(find.text('Shot 2'), findsOneWidget);
    expect(find.text('Add shot'), findsOneWidget);
  });
}

Widget _buildTestApp({required _TestVaccinationViewModel Function() viewModelFactory}) {
  return ProviderScope(
    overrides: [vaccinationsProvider.overrideWith(viewModelFactory)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {Routes.vaccinationEdit: (_) => const Scaffold(body: Center(child: Text('Vaccination Edit Stub')))},
      home: const VaccinationsScreen(),
    ),
  );
}
