import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Custom header ──────────────────────────────────────────────
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    local.settings,
                    style: textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Section: Appearance ────────────────────────────────────────
              _SectionHeader(label: local.appearance.toUpperCase()),
              const SizedBox(height: 12),
              _SettingsCard(
                colorScheme: colorScheme,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.dark_mode_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        local.darkMode,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: settings.isDarkMode,
                      onChanged: (value) => notifier.setDarkMode(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Section: Language ──────────────────────────────────────────
              _SectionHeader(label: local.language.toUpperCase()),
              const SizedBox(height: 12),
              Row(
                children: [
                  _LanguageChip(
                    label: '🇬🇧 English',
                    code: 'en',
                    selected: settings.locale.languageCode == 'en',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: () => notifier.setLanguage('en'),
                  ),
                  const SizedBox(width: 12),
                  _LanguageChip(
                    label: '🇩🇪 Deutsch',
                    code: 'de',
                    selected: settings.locale.languageCode == 'de',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: () => notifier.setLanguage('de'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Section: Reminders ─────────────────────────────────────────
              _SectionHeader(label: local.reminders.toUpperCase()),
              const SizedBox(height: 12),
              _SettingsCard(
                colorScheme: colorScheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.reminderLeadTimeLabel,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepButton(
                          icon: Icons.remove,
                          colorScheme: colorScheme,
                          onPressed: settings.leadTimeDays > 7
                              ? () {
                                  final newVal = settings.leadTimeDays - 1;
                                  notifier.setLeadTimeDays(newVal);
                                  ref.invalidate(vaccinationRemindersProvider);
                                }
                              : null,
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 80,
                          child: Text(
                            local.days(settings.leadTimeDays),
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        _StepButton(
                          icon: Icons.add,
                          colorScheme: colorScheme,
                          onPressed: settings.leadTimeDays < 90
                              ? () {
                                  final newVal = settings.leadTimeDays + 1;
                                  notifier.setLeadTimeDays(newVal);
                                  ref.invalidate(vaccinationRemindersProvider);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Section: About ─────────────────────────────────────────────
              _SectionHeader(label: local.about.toUpperCase()),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'VaccineCare',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      local.appVersion('1.0.0'),
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header widget
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontFamily: 'Inter',
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings card (surfaceContainerLow background, rounded-2xl)
// ---------------------------------------------------------------------------
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.colorScheme, required this.child});

  final ColorScheme colorScheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Language chip
// ---------------------------------------------------------------------------
class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.code,
    required this.selected,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final String label;
  final String code;
  final bool selected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step button (–/+ for stepper)
// ---------------------------------------------------------------------------
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.colorScheme,
    required this.onPressed,
  });

  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerHigh,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

