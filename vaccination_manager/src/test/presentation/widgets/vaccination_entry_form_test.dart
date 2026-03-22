import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_entry_form.dart';

void main() {
  group('VaccinationEntryForm', () {
    testWidgets('shows validation for empty values', (tester) async {
      await tester.pumpWidget(_buildTestApp(onSubmit: (name, shotDates, expirationDate) async {}));

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a vaccination name.'), findsOneWidget);
      expect(find.text('Please add at least one shot date.'), findsOneWidget);
      expect(find.text('Please select the vaccination expiration date.'), findsOneWidget);
    });

    testWidgets('submits with multiple shot dates and expiration date', (tester) async {
      String? savedName;
      List<DateTime>? savedShots;
      DateTime? savedExpiration;

      await tester.pumpWidget(
        _buildTestApp(
          initialMode: VaccinationCourseMode.multiShot,
          initialShotDates: [DateTime(2026, 1, 10), DateTime(2026, 4, 10)],
          initialExpirationDate: DateTime(2026, 10, 10),
          onSubmit: (name, shotDates, expirationDate) async {
            savedName = name;
            savedShots = shotDates;
            savedExpiration = expirationDate;
          },
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'FSME');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(savedName, 'FSME');
      expect(savedShots, [DateTime(2026, 1, 10), DateTime(2026, 4, 10)]);
      expect(savedExpiration, DateTime(2026, 10, 10));
    });

    testWidgets('warns before switching from multi-shot to one-shot when data would be lost', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(initialMode: VaccinationCourseMode.multiShot, initialShotDates: [DateTime(2026, 1, 10), DateTime(2026, 4, 10)], initialExpirationDate: DateTime(2026, 10, 10), onSubmit: (name, shotDates, expirationDate) async {}),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'One-shot'));
      await tester.pumpAndSettle();

      expect(find.text('Convert to one-shot?'), findsOneWidget);
      await tester.tap(find.text('Convert'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
    });
  });
}

Widget _buildTestApp({required VaccinationEntrySubmit onSubmit, VaccinationCourseMode? initialMode, List<DateTime>? initialShotDates, DateTime? initialExpirationDate}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: VaccinationEntryForm(submitLabel: 'Save', onSubmit: onSubmit, initialMode: initialMode, initialShotDates: initialShotDates, initialExpirationDate: initialExpirationDate),
        ),
      ),
    ),
  );
}
