import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/state/load_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/errors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/shimmer.dart';
import '../data/content_repository.dart';

/// Help centre: header, FAQ (with helpful votes) and links to contact/privacy/terms.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key, this.faqOnly = false});

  final bool faqOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(faqOnly ? 'faq' : 'help'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (!faqOnly) ...[
            const _Header(),
            const SizedBox(height: 20),
          ],
          _Section(title: context.tr('faq'), child: const _FaqList()),
          if (!faqOnly) ...[
            const SizedBox(height: 20),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded),
                    title: Text(context.tr('contact_us')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.contact),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(context.tr('privacy_policy')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.privacy),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(context.tr('terms_conditions')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.terms),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.help_center_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              context.tr('message_hint'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SectionHeader(title: title), const SizedBox(height: 8), child],
      );
}

class _FaqList extends StatefulWidget {
  const _FaqList();

  @override
  State<_FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<_FaqList> {
  Future<List<Faq>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Faq>> _load() =>
      sl<ContentRepository>().fetchFaqs().timeout(loadTimeout);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Faq>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const ListSkeleton(count: 4);
        if (snap.hasError) {
          return ErrorView(errorKey: errorKey(snap.error!), onRetry: () => setState(() {
              _future = _load();
            }));
        }
        final faqs = snap.data ?? const [];
        if (faqs.isEmpty) return EmptyState(message: context.tr('no_content'));
        return Column(children: [for (final f in faqs) _FaqTile(faq: f)]);
      },
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.faq});

  final Faq faq;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  late int _likes = widget.faq.likeCount;
  late int _unlikes = widget.faq.unlikeCount;
  bool? _vote; // true = helpful, false = not helpful

  Future<void> _castVote(bool helpful) async {
    if (_vote == helpful) return;
    final previous = _vote;
    setState(() {
      if (previous == true) _likes--;
      if (previous == false) _unlikes--;
      helpful ? _likes++ : _unlikes++;
      _vote = helpful;
    });
    try {
      await sl<ContentRepository>().voteFaq(widget.faq.id, likes: _likes, unlikes: _unlikes);
      if (mounted) showSnack(context, 'vote_thanks');
    } catch (e) {
      if (mounted) showSnack(context, errorKey(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(widget.faq.question, style: const TextStyle(fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.faq.answer, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(context.tr('faq_helpful'), style: Theme.of(context).textTheme.bodySmall)),
                _VoteButton(icon: Icons.thumb_up_alt_outlined, count: _likes, active: _vote == true, onTap: () => _castVote(true)),
                const SizedBox(width: 8),
                _VoteButton(icon: Icons.thumb_down_alt_outlined, count: _unlikes, active: _vote == false, onTap: () => _castVote(false)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({required this.icon, required this.count, required this.active, required this.onTap});

  final IconData icon;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 4), Text('$count', style: TextStyle(color: color))]),
      ),
    );
  }
}
