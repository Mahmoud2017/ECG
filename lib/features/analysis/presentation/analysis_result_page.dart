import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../data/ecg_analysis.dart';
import '../data/patient.dart';

Color severityColor(Severity s) => switch (s) {
      Severity.normal => AppColors.success,
      Severity.borderline => AppColors.warning,
      Severity.abnormal => AppColors.danger,
    };

class AnalysisResultPage extends StatelessWidget {
  const AnalysisResultPage({super.key, this.patient, this.analysis});

  final Patient? patient;
  final EcgAnalysis? analysis;

  @override
  Widget build(BuildContext context) {
    final a = analysis ?? patient?.analysis;
    final text = Theme.of(context).textTheme;
    if (a == null) return _PatientOnly(patient: patient);
    final color = severityColor(a.severity);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('analysis_result'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(context.tr('severity_${a.severity.name}'), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text('${(a.confidence * 100).round()}%', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                if (patient != null) ...[
                  const SizedBox(height: 12),
                  Text(patient!.patientCode, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    [
                      '${context.tr('age')}: ${patient!.age}',
                      context.tr('sex_${patient!.sex}'),
                      if (patient!.leadConfiguration != null) patient!.leadConfiguration!,
                      if (patient!.samplingRate != null) '${patient!.samplingRate} Hz',
                    ].join(' · '),
                    style: text.bodySmall,
                  ),
                  Text(DateFormat.yMMMd(locale).add_jm().format(patient!.createdAt), style: text.bodySmall),
                ],
                const SizedBox(height: 12),
                Text(a.summary, style: text.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _Metric(icon: Icons.favorite_rounded, label: context.tr('heart_rate'), value: '${a.heartRate}', unit: 'bpm'),
              _Metric(icon: Icons.timeline_rounded, label: context.tr('pr_interval'), value: '${a.prInterval}', unit: 'ms'),
              _Metric(icon: Icons.show_chart_rounded, label: context.tr('qrs_duration'), value: '${a.qrsDuration}', unit: 'ms'),
              _Metric(icon: Icons.multiline_chart_rounded, label: context.tr('qtc_interval'), value: '${a.qtcInterval}', unit: 'ms'),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('findings'), style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final f in a.findings)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 18, color: color),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f)),
                      ],
                    ),
                  ),
                if (patient?.notes != null) ...[
                  const Divider(height: 24),
                  Text(context.tr('clinical_notes'), style: text.labelLarge),
                  const SizedBox(height: 4),
                  Text(patient!.notes!),
                ],
                const Divider(height: 24),
                Text('${context.tr('engine')}: ${a.engine}', style: text.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('ai_disclaimer'),
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value, required this.unit});

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: text.bodySmall, overflow: TextOverflow.ellipsis)),
            ],
          ),
          Text.rich(TextSpan(children: [
            TextSpan(text: value, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            TextSpan(text: ' $unit', style: text.bodySmall),
          ])),
        ],
      ),
    );
  }
}

/// A saved patient opened from History: the live database keeps no analysis results.
class _PatientOnly extends StatelessWidget {
  const _PatientOnly({required this.patient});

  final Patient? patient;

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(p?.patientCode ?? '')),
      body: p == null
          ? EmptyState(message: context.tr('no_reports'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.patientCode, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${context.tr('age')}: ${p.age} · ${context.tr('sex_${p.sex}')}', style: text.bodySmall),
                      Text(
                        DateFormat.yMMMd(Localizations.localeOf(context).languageCode).add_jm().format(p.createdAt),
                        style: text.bodySmall,
                      ),
                      if (p.notes != null && p.notes!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(context.tr('clinical_notes'), style: text.labelLarge),
                        const SizedBox(height: 4),
                        Text(p.notes!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                EmptyState(message: context.tr('no_saved_analysis')),
              ],
            ),
    );
  }
}
