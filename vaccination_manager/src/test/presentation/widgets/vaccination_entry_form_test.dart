import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_entry_form.dart';

void main() {
  group('VaccinationEntryForm', () {
    testWidgets('shows validation for empty values', (tester) async {
      await tester.pumpWidget(_buildTestApp(onSubmit: (name, vaccinationDate, nextVaccinationRequiredDate) async {}));

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a vaccination name.'), findsOneWidget);
      expect(find.text('Please select the vaccination date.'), findsOneWidget);
      expect(find.text('Please select the next vaccination date.'), findsOneWidget);
    });

    testWidgets('submits when initial dates and valid name are present', (tester) async {
      String? savedName;

      await tester.pumpWidget(
        _buildTestApp(
          initialVaccinationDate: DateTime(2026, 1, 10),
          initialNextVaccinationRequiredDate: DateTime(2026, 7, 10),
          onSubmit: (name, vaccinationDate, nextVaccinationRequiredDate) async {
            savedName = name;
            expect(vaccinationDate, DateTime(2026, 1, 10));
            expect(nextVaccinationRequiredDate, DateTime(2026, 7, 10));
          },
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'FSME');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(savedName, 'FSME');
    });
  });
}

Widget _buildTestApp({required VaccinationEntrySubmit onSubmit, DateTime? initialVaccinationDate, DateTime? initialNextVaccinationRequiredDate}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: VaccinationEntryForm(submitLabel: 'Save', onSubmit: onSubmit, initialVaccinationDate: initialVaccinationDate, initialNextVaccinationRequiredDate: initialNextVaccinationRequiredDate),
      ),
    ),
  );
}
