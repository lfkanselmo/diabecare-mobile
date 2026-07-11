import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../providers/report_providers.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int _selectedDays = 30;
  bool _isGenerating = false;

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isGenerating = true);
    try {
      final to = DateTime.now();
      final from = to.subtract(Duration(days: _selectedDays));
      await ref.read(reportRepositoryProvider).generateAndShare(from: from, to: to);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.reportErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ranges = {7: l10n.reportLast7Days, 14: l10n.reportLast14Days, 30: l10n.reportLast30Days, 90: l10n.reportLast90Days};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.reportDescription),
              const SizedBox(height: 24),
              Text(l10n.reportRange, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in ranges.entries)
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: _selectedDays == entry.key,
                      onSelected: (_) => setState(() => _selectedDays = entry.key),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: _isGenerating ? l10n.reportGenerating : l10n.reportGenerate,
                isLoading: _isGenerating,
                onPressed: _generate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
