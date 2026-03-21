import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/widgets/user_profile_form.dart';

void main() {
  group('UserProfileForm', () {
    testWidgets('shows validation error for empty username', (tester) async {
      await tester.pumpWidget(_buildTestApp(onSubmit: (username, picture) async {}));

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a username.'), findsOneWidget);
    });

    testWidgets('submits trimmed username when valid', (tester) async {
      String? submittedUsername;

      await tester.pumpWidget(
        _buildTestApp(
          onSubmit: (username, picture) async {
            submittedUsername = username;
            expect(picture, isNull);
          },
        ),
      );

      await tester.enterText(find.byType(TextFormField), '  Anna  ');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(submittedUsername, 'Anna');
    });

    testWidgets('renders cancel button when callback is provided', (tester) async {
      var canceled = false;
      await tester.pumpWidget(_buildTestApp(onSubmit: (username, picture) async {}, onCancel: () => canceled = true));

      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(canceled, isTrue);
    });
  });
}

Widget _buildTestApp({required UserProfileSubmit onSubmit, VoidCallback? onCancel}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: UserProfileForm(submitLabel: 'Save', onSubmit: onSubmit, onCancel: onCancel),
      ),
    ),
  );
}
