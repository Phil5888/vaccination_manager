import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_series_card.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final seriesAsync = ref.watch(seriesListProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          seriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('${local.error}: $e',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.error)),
            ),
            data: (seriesList) {
              if (seriesList.isEmpty) {
                return _EmptyState(
                  local: local,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  topPadding: topPadding,
                );
              }
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, topPadding + 72, 20, bottomPadding + 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: seriesList.map((series) {
                    return VaccinationSeriesCard(
                      series: series,
                      onEdit: () => Navigator.of(context).pushNamed(
                        Routes.vaccinationAdd,
                        arguments: series,
                      ),
                      onDelete: () =>
                          _confirmDelete(context, ref, series, local,
                              colorScheme),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // Glassmorphic top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: topPadding + 64,
                  color: colorScheme.surfaceContainerLowest
                      .withValues(alpha: 0.8),
                  padding:
                      EdgeInsets.only(top: topPadding, left: 20, right: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            local.vaccinationRecords,
                            style: textTheme.titleLarge?.copyWith(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(Routes.vaccinationAdd),
                          icon: Icon(Icons.add, color: colorScheme.primary),
                          tooltip: local.addVaccination,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FAB moved to Scaffold.floatingActionButton
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VaccinationSeriesEntity series,
    AppLocalizations local,
    ColorScheme colorScheme,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(local.deleteSeriesTitle),
        content: Text(local.deleteSeriesConfirm(series.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: Text(local.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(vaccinationProvider.notifier)
          .deleteSeries(series.userId, series.name);
    }
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.local,
    required this.colorScheme,
    required this.textTheme,
    required this.topPadding,
  });

  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding + 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines_outlined,
                size: 56, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              local.noVaccinationRecords,
              style: textTheme.titleMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.vaccinationAdd),
              icon: const Icon(Icons.add),
              label: Text(local.addVaccination),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


