import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/load_cubit.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/shimmer.dart';
import '../../analysis/data/patient.dart';
import 'patients_cubit.dart';
import 'widgets/patient_tile.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _cubit = sl<PatientsCubit>();

  @override
  void initState() {
    super.initState();
    if (_cubit.state.data == null) _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('nav_history'))),
      body: BlocBuilder<PatientsCubit, LoadState<List<Patient>>>(
        bloc: _cubit,
        builder: (context, state) {
          final list = state.data;
          if (list == null && state.status != LoadStatus.failure) {
            return const Padding(padding: EdgeInsets.all(16), child: ListSkeleton());
          }
          if (list == null) return ErrorView(errorKey: state.error!, onRetry: _cubit.load);
          return RefreshIndicator(
            onRefresh: _cubit.load,
            child: list.isEmpty
                ? ListView(children: [const SizedBox(height: 80), EmptyState(message: context.tr('no_reports'))])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (_, i) => PatientTile(patient: list[i]),
                  ),
          );
        },
      ),
    );
  }
}
