import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_series_card.dart';

import '../../helpers/fakes/fake_active_user_notifier.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/screen_sizes.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Builds a localised ProviderScope tree around [child].
Widget buildTestApp(Widget child) {
  return ProviderScope(child: _localizedApp(child: child));
}

/// Returns the standard localization delegates & locales config for MaterialApp.
Widget _localizedApp({required Widget child}) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

VaccinationSeriesEntity _completeSeries() {
  final shots = [
    Fixtures.singleShotPast(name: 'Flu', userId: 1).copyWith(
      id: 1,
      shotNumber: 1,
      totalShots: 1,
    ),
  ];
  return VaccinationSeriesEntity(name: 'Flu', userId: 1, shots: shots);
}

VaccinationSeriesEntity _inProgressSeries() {
  final shots = Fixtures.threeShots(
    name: 'COVID-19',
    userId: 1,
    d1: Fixtures.thirtyDaysAgo,
    d2: Fixtures.yesterday,
    d3: null,
  ).asMap().entries.map((e) => e.value.copyWith(id: e.key + 1)).toList();
  return VaccinationSeriesEntity(name: 'COVID-19', userId: 1, shots: shots);
}

VaccinationSeriesEntity _plannedSeries() {
  final shots = [
    Fixtures.singleShotFuture(name: 'Hepatitis A', userId: 1).copyWith(id: 10),
  ];
  return VaccinationSeriesEntity(
      name: 'Hepatitis A', userId: 1, shots: shots);
}

VaccinationSeriesEntity _overdueSeries() {
  final shots = [
    Fixtures.singleShotComplete(
      name: 'Tetanus',
      userId: 1,
      nextVaccinationDate: Fixtures.thirtyDaysAgo,
    ).copyWith(id: 20),
  ];
  return VaccinationSeriesEntity(name: 'Tetanus', userId: 1, shots: shots);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('VaccinationSeriesCard', () {
    group('displays vaccine name', () {
      testWidgets('shows the series name', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _completeSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        expect(find.text('Flu'), findsOneWidget);
      });
    });

    group('status badge', () {
      testWidgets('complete series shows "Complete" badge', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _completeSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        expect(find.text('Complete'), findsOneWidget);
      });

      testWidgets('inProgress series shows "In Progress" badge', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _inProgressSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        expect(find.text('In Progress'), findsOneWidget);
      });

      testWidgets('planned series shows "Planned" badge', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _plannedSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        expect(find.text('Planned'), findsOneWidget);
      });

      testWidgets('overdue series shows "Overdue" badge', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _overdueSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        expect(find.text('Overdue'), findsOneWidget);
      });
    });

    group('progress text', () {
      testWidgets('shows "Done X of Y" text', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _inProgressSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        // inProgressSeries has 2 of 3 shots completed
        expect(find.textContaining('Done 2 of 3'), findsOneWidget);
      });

      testWidgets('shows percentage', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _inProgressSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        expect(find.textContaining('67%'), findsOneWidget);
      });
    });

    group('expand / collapse', () {
      testWidgets('shot timeline is hidden by default', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _inProgressSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        // "Show details" label visible, shot rows not yet visible
        expect(find.text('Show details'), findsOneWidget);
        expect(find.text('Hide details'), findsNothing);
      });

      testWidgets('tapping expand toggle reveals shot timeline', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _inProgressSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show details'));
        await tester.pumpAndSettle();

        expect(find.text('Hide details'), findsOneWidget);
        // Shot rows for a 3-shot series become visible: "Shot 1", "Shot 2", "Shot 3"
        expect(find.textContaining('Shot 1'), findsWidgets);
        expect(find.textContaining('Shot 2'), findsWidgets);
        expect(find.textContaining('Shot 3'), findsWidgets);
      });

      testWidgets('tapping expand again collapses timeline', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _inProgressSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show details'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hide details'));
        await tester.pumpAndSettle();

        expect(find.text('Show details'), findsOneWidget);
      });
    });

    group('"Record Next Shot" button', () {
      testWidgets('visible when series is inProgress', (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            activeUserProvider
                .overrideWith(() => FakeActiveUserNotifier(Fixtures.userAlice())),
            vaccinationRepositoryProvider
                .overrideWith((_) => FakeVaccinationRepository()),
          ],
          child: _localizedApp(
            child: VaccinationSeriesCard(
              series: _inProgressSeries(),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.text('Record Next Shot'), findsOneWidget);
      });

      testWidgets('visible when series is planned', (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            activeUserProvider
                .overrideWith(() => FakeActiveUserNotifier(Fixtures.userAlice())),
            vaccinationRepositoryProvider
                .overrideWith((_) => FakeVaccinationRepository()),
          ],
          child: _localizedApp(
            child: VaccinationSeriesCard(
              series: _plannedSeries(),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.text('Record Next Shot'), findsOneWidget);
      });

      testWidgets('hidden when series is complete', (tester) async {
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _completeSeries(),
          onEdit: () {},
          onDelete: () {},
        )));
        await tester.pumpAndSettle();
        expect(find.text('Record Next Shot'), findsNothing);
      });
    });

    group('callbacks', () {
      testWidgets('onEdit is called when Edit button tapped', (tester) async {
        var editCalled = false;
        await tester.pumpWidget(buildTestApp(VaccinationSeriesCard(
          series: _completeSeries(),
          onEdit: () => editCalled = true,
          onDelete: () {},
        )));
        await tester.pumpAndSettle();

        // The edit icon button
        await tester.tap(find.byIcon(Icons.edit_outlined));
        expect(editCalled, isTrue);
      });
    });

    group('no overflow at any screen size', () {
      Widget scopedCard(VaccinationSeriesEntity series) => ProviderScope(
            overrides: [
              activeUserProvider.overrideWith(
                  () => FakeActiveUserNotifier(Fixtures.userAlice())),
              vaccinationRepositoryProvider
                  .overrideWith((_) => FakeVaccinationRepository()),
            ],
            child: _localizedApp(
              child: VaccinationSeriesCard(
                series: series,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          );

      for (final size in allScreenSizes) {
        testWidgets('complete card at ${size.width}x${size.height}',
            (tester) async {
          await pumpAtSize(tester, () => scopedCard(_completeSeries()), size);
          expectNoOverflow(tester);
        });

        testWidgets('inProgress card at ${size.width}x${size.height}',
            (tester) async {
          await pumpAtSize(
              tester, () => scopedCard(_inProgressSeries()), size);
          expectNoOverflow(tester);
        });

        testWidgets('expanded card at ${size.width}x${size.height}',
            (tester) async {
          await pumpAtSize(
              tester, () => scopedCard(_inProgressSeries()), size);
          // Tap "Show details" to expand
          await tester.tap(find.text('Show details'));
          await tester.pumpAndSettle();
          expectNoOverflow(tester);
        });
      }
    });
  });
}
