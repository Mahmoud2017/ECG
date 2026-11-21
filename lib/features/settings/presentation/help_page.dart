import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/state/load_cubit.dart';
import '../../../core/utils/errors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/shimmer.dart';
import '../../contact/data/contact_repository.dart';
import '../../contact/presentation/widgets/follow_us.dart';
import '../data/content_repository.dart';

/// Help hub (FAQ / Privacy / Terms / Contact) or, with [faqOnly], the FAQ list
/// with a "Follow Us" footer.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key, this.faqOnly = false});

  final bool faqOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TitleAppBar(title: context.tr(faqOnly ? 'faq' : 'help')),
      body: faqOnly ? const _FaqBody() : const _HelpHub(),
    );
  }
}

class _HelpHub extends StatelessWidget {
  const _HelpHub();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.quiz_outlined, 'faq', Routes.faq),
      (Icons.privacy_tip_outlined, 'privacy_policy', Routes.privacy),
      (Icons.description_outlined, 'terms_conditions', Routes.terms),
      (Icons.support_agent_rounded, 'contact_us', Routes.contact),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _HubTile(icon: items[i].$1, title: context.tr(items[i].$2), onTap: () => context.push(items[i].$3)),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final blue = pageTitleColor(context);
    return OutlinedCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          Icon(icon, color: blue, size: 28),
          const SizedBox(width: 18),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17))),
          Icon(Icons.chevron_right_rounded, color: blue),
        ],
      ),
    );
  }
}

class _FaqBody extends StatefulWidget {
  const _FaqBody();

  @override
  State<_FaqBody> createState() => _FaqBodyState();
}

class _FaqBodyState extends State<_FaqBody> {
  late Future<List<Faq>> _future = _load();
  ContactLinks? _links;

  @override
  void initState() {
    super.initState();
    // Footer is optional: a failure just hides it.
    sl<ContactRepository>().fetchLinks().timeout(loadTimeout).then((l) {
      if (mounted) setState(() => _links = l);
    }, onError: (_) {});
  }

  Future<List<Faq>> _load() => sl<ContentRepository>().fetchFaqs().timeout(loadTimeout);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Faq>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(padding: EdgeInsets.all(20), child: ListSkeleton(count: 4));
        }
        if (snap.hasError) {
          return ErrorView(
            errorKey: errorKey(snap.error!),
            onRetry: () => setState(() {
              _future = _load();
            }),
          );
        }
        final faqs = snap.data ?? const [];
        if (faqs.isEmpty) return EmptyState(message: context.tr('no_content'));
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            for (final f in faqs) _FaqTile(faq: f),
            if (_links != null) ...[
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 20),
              FollowUsSection(links: _links!, inline: true),
            ],
          ],
        );
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
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: OutlinedCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            iconColor: Theme.of(context).textTheme.bodyLarge?.color,
            collapsedIconColor: Theme.of(context).textTheme.bodyLarge?.color,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Text(widget.faq.question, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 17)),
            children: [
              Text(widget.faq.answer, style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor, height: 1.6)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(context.tr('faq_helpful'), style: text.bodySmall?.copyWith(color: Theme.of(context).hintColor))),
                  _VoteButton(icon: Icons.thumb_up_alt_outlined, count: _likes, active: _vote == true, onTap: () => _castVote(true)),
                  const SizedBox(width: 4),
                  _VoteButton(icon: Icons.thumb_down_alt_outlined, count: _unlikes, active: _vote == false, onTap: () => _castVote(false)),
                ],
              ),
            ],
          ),
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
    final color = active ? pageTitleColor(context) : Theme.of(context).hintColor;
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
