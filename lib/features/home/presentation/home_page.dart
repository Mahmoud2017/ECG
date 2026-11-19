import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/state/load_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/shimmer.dart';
import '../../analysis/data/ecg_analysis.dart';
import '../../analysis/data/patient.dart';
import '../../history/presentation/patients_cubit.dart';
import '../../history/presentation/widgets/patient_tile.dart';
import '../../profile/data/profile.dart';
import '../../profile/presentation/profile_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _patients = sl<PatientsCubit>();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await Future.wait([_patients.load(), context.read<ProfileCubit>().load()]);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<ProfileCubit, LoadState<Profile>>(
                      builder: (context, s) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('hello'), style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
                          Text(
                            s.data?.fullName ?? '',
                            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const AppLogo(height: 40, markOnly: true),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<PatientsCubit, LoadState<List<Patient>>>(
                bloc: _patients,
                builder: (context, s) {
                  final list = s.data ?? const <Patient>[];
                  final abnormal = list.where((p) => (p.analysis?.severity ?? Severity.normal) != Severity.normal).length;
                  return Row(
                    children: [
                      Expanded(child: _StatCard(icon: Icons.groups_rounded, label: context.tr('total_patients'), value: s.data == null ? '—' : '${list.length}')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(icon: Icons.warning_amber_rounded, label: context.tr('severity_abnormal'), value: s.data == null ? '—' : '$abnormal', color: AppColors.danger)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              const _StartAnalysisCard(),
              const SizedBox(height: 24),
              SectionHeader(title: context.tr('recent_patients'), onSeeAll: () => context.go(Routes.history)),
              const SizedBox(height: 8),
              BlocBuilder<PatientsCubit, LoadState<List<Patient>>>(
                bloc: _patients,
                builder: (context, s) {
                  if (s.data == null && s.status != LoadStatus.failure) return const ListSkeleton(count: 3);
                  if (s.data == null) return ErrorView(errorKey: s.error!, onRetry: _patients.load);
                  final recent = s.data!.take(5).toList();
                  if (recent.isEmpty) return EmptyState(message: context.tr('no_patients_yet'));
                  return Column(children: [for (final p in recent) PatientTile(patient: p)]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: c.withValues(alpha: 0.12), child: Icon(icon, color: c)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartAnalysisCard extends StatelessWidget {
  const _StartAnalysisCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('start_analysis_title'), style: text.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(context.tr('start_analysis_body'), style: text.bodySmall?.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(minimumSize: const Size(120, 40)),
                  onPressed: () => context.go(Routes.analysis),
                  child: Text(context.tr('start_now')),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.monitor_heart_rounded, size: 64, color: Colors.white),
        ],
      ),
    );
  }
}
