import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/state/load_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/shimmer.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              BlocBuilder<ProfileCubit, LoadState<Profile>>(
                builder: (context, s) => Row(
                  children: [
                    _Avatar(profile: s.data),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('hello'), style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
                          Text(
                            s.data?.fullName ?? '',
                            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _StartAnalysisCard(),
              const SizedBox(height: 20),
              BlocBuilder<PatientsCubit, LoadState<List<Patient>>>(
                bloc: _patients,
                builder: (context, s) {
                  final list = s.data ?? const <Patient>[];
                  final now = DateTime.now();
                  final today = list.where((p) => DateUtils.isSameDay(p.createdAt, now)).length;
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.groups_outlined,
                          label: context.tr('total_patients'),
                          value: s.data == null ? '—' : '${list.length}',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_month_outlined,
                          label: context.tr('today'),
                          value: s.data == null ? '—' : '$today',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              BlocBuilder<PatientsCubit, LoadState<List<Patient>>>(
                bloc: _patients,
                builder: (context, s) => SectionHeader(
                  title: context.tr('recent_patients'),
                  onSeeAll: (s.data?.isNotEmpty ?? false) ? () => context.go(Routes.history) : null,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<PatientsCubit, LoadState<List<Patient>>>(
                bloc: _patients,
                builder: (context, s) {
                  if (s.data == null && s.status != LoadStatus.failure) return const ListSkeleton(count: 3);
                  if (s.data == null) return ErrorView(errorKey: s.error!, onRetry: _patients.load);
                  final recent = s.data!.take(5).toList();
                  if (recent.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        context.tr('no_patients_yet'),
                        textAlign: TextAlign.center,
                        style: text.bodyLarge?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    );
                  }
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

class _Avatar extends StatelessWidget {
  const _Avatar({this.profile});

  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    final url = profile?.avatarUrl;
    return CircleAvatar(
      radius: 30,
      backgroundColor: AppColors.brand.withValues(alpha: 0.1),
      foregroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
      child: Text(
        profile?.initials ?? '',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.brand),
      ),
    );
  }
}

/// Outlined stat tile: blue line icon, big number, muted label.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Colors.white12 : AppColors.fieldBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 4), child: Icon(icon, color: AppColors.brand, size: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w500, height: 1.1)),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
      padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.brand, Color(0xFF1366E0)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('new_ecg_analysis'),
                  style: text.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('start_analysis_body'),
                  style: text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.brand,
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: const StadiumBorder(),
                    textStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  onPressed: () => context.go(Routes.analysis),
                  child: Text(context.tr('start_now')),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 78,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.monitor_heart_outlined, size: 44, color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}
