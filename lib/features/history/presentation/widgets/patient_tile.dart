import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/common.dart';
import '../../../analysis/data/patient.dart';
import '../../../analysis/presentation/analysis_result_page.dart';

class PatientTile extends StatelessWidget {
  const PatientTile({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final a = patient.analysis;
    final color = a == null ? Theme.of(context).colorScheme.primary : severityColor(a.severity);
    final subtitle = a == null
        ? '${context.tr('age')}: ${patient.age} · ${context.tr('sex_${patient.sex}')}'
        : '${context.tr('severity_${a.severity.name}')} · ${a.heartRate} bpm';
    final text = Theme.of(context).textTheme;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(patient.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push(Routes.analysisResult, extra: patient),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(Icons.monitor_heart_rounded, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.patientCode, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: text.bodySmall?.copyWith(color: a == null ? null : color)),
                  Text(date, style: text.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
