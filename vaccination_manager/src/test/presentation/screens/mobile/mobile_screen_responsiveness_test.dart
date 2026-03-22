import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vaccination_manager/presentation/screens/users/user_management_screen.dart';
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccinations_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';

class _TestUserManagementViewModel extends UserManagementViewModel {
  _TestUserManagementViewModel(this.initialState);

  final UserManagementState initialState;

  @override
  Future<UserManagementState> build() async => initialState;
}

class _TestVaccinationViewModel extends VaccinationViewModel {
  _TestVaccinationViewModel(this.initialState);

  final VaccinationOverviewState initialState;

  @override
  Future<VaccinationOverviewState> build() async => initialState;
}

class _DeviceProfile {
  const _DeviceProfile(this.name, this.size);

  final String name;
  final Size size;

  _DeviceProfile toLandscape() {
    return _DeviceProfile('$name landscape', Size(size.height, size.width));
  }
}

void main() {
  const portraitDevices = <_DeviceProfile>[
    _DeviceProfile('iPhone SE (1st gen)', Size(320, 568)),
    _DeviceProfile('iPhone 12 mini', Size(360, 780)),
    _DeviceProfile('iPhone 12', Size(390, 844)),
    _DeviceProfile('iPhone 12 Pro Max', Size(428, 926)),
    _DeviceProfile('iPhone 14 Pro', Size(393, 852)),
    _DeviceProfile('iPhone 15 Pro Max', Size(430, 932)),
  ];

  final landscapeDevices = portraitDevices.where((device) => device.name != 'iPhone 12 mini').map((device) => device.toLandscape()).toList();

  final activeUser = AppUserEntity(id: 1, username: 'Alex', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));

  final vaccinationSeries = VaccinationSeriesEntity(
    name: 'COVID-19',
    entries: [
      VaccinationEntryEntity(
        id: 1,
        userId: 1,
        name: 'COVID-19',
        vaccinationDate: DateTime.now().subtract(const Duration(days: 20)),
        nextVaccinationRequiredDate: DateTime.now().add(const Duration(days: 12)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      VaccinationEntryEntity(
        id: 2,
        userId: 1,
        name: 'COVID-19',
        vaccinationDate: DateTime.now().subtract(const Duration(days: 300)),
        nextVaccinationRequiredDate: DateTime.now().add(const Duration(days: 12)),
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
    ],
  );

  void addScreenResponsivenessTests(List<_DeviceProfile> devices) {
    for (final device in devices) {
      testWidgets('Dashboard screen renders without layout exception on ${device.name}', (tester) async {
        await tester.binding.setSurfaceSize(device.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _buildTestApp(
            screen: const DashboardScreen(),
            userState: UserManagementState(users: [activeUser], activeUser: activeUser),
            vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: [vaccinationSeries]),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Welcome back, Alex'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Vaccinations screen renders and expands without layout exception on ${device.name}', (tester) async {
        await tester.binding.setSurfaceSize(device.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _buildTestApp(
            screen: const VaccinationsScreen(),
            userState: UserManagementState(users: [activeUser], activeUser: activeUser),
            vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: [vaccinationSeries]),
          ),
        );

        await tester.pumpAndSettle();

        final seriesTile = find.widgetWithText(ExpansionTile, 'COVID-19');
        await tester.dragUntilVisible(seriesTile, find.byType(Scrollable).first, const Offset(0, -160));
        await tester.pumpAndSettle();
        await tester.tap(seriesTile);
        await tester.pumpAndSettle();

        expect(find.text('Shot 2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('User management screen renders without layout exception on ${device.name}', (tester) async {
        await tester.binding.setSurfaceSize(device.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final users = [activeUser, AppUserEntity(id: 2, username: 'Jordan', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2))];

        await tester.pumpWidget(
          _buildTestApp(
            screen: const UserManagementScreen(),
            userState: UserManagementState(users: users, activeUser: activeUser),
            vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: const []),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Alex'), findsOneWidget);
        expect(find.text('Jordan'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  addScreenResponsivenessTests(portraitDevices);
  addScreenResponsivenessTests(landscapeDevices);
}

Widget _buildTestApp({required Widget screen, required UserManagementState userState, required VaccinationOverviewState vaccinationState}) {
  return ProviderScope(
    overrides: [userManagementProvider.overrideWith(() => _TestUserManagementViewModel(userState)), vaccinationsProvider.overrideWith(() => _TestVaccinationViewModel(vaccinationState))],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {Routes.userEdit: (_) => const Scaffold(), Routes.vaccinationEdit: (_) => const Scaffold()},
      home: screen,
    ),
  );
}
