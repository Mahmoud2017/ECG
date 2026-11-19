import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/load_cubit.dart';
import '../../../core/utils/errors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/shimmer.dart';
import '../data/content_repository.dart';

/// Privacy policy / terms page: ordered sections from the `privacyPolicy` / `terms` tables.
class ContentPage extends StatefulWidget {
  const ContentPage({super.key, required this.kind});

  /// 'privacy' or 'terms'
  final String kind;

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late Future<ContentDoc> _future = _load();

  String get _titleKey => widget.kind == 'privacy' ? 'privacy_policy' : 'terms_conditions';
  String get _subKey => widget.kind == 'privacy' ? 'privacy_header_sub' : 'terms_header_sub';

  Future<ContentDoc> _load() => sl<ContentRepository>().fetchDoc(widget.kind).timeout(loadTimeout);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(_titleKey))),
      body: FutureBuilder<ContentDoc>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(padding: EdgeInsets.all(16), child: ListSkeleton(count: 6));
          }
          if (snap.hasError) {
            return ErrorView(
              errorKey: errorKey(snap.error!),
              onRetry: () => setState(() {
                _future = _load();
              }),
            );
          }
          final doc = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(context.tr(_subKey), style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
              if (doc.updatedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${context.tr('last_updated')}: ${DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(doc.updatedAt!)}',
                  style: text.bodySmall,
                ),
              ],
              const SizedBox(height: 20),
              if (doc.sections.isEmpty)
                EmptyState(message: context.tr('no_content'))
              else
                for (final (i, s) in doc.sections.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${i + 1}. ${s.title}', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        SelectableText(s.body, style: text.bodyMedium?.copyWith(height: 1.6)),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
