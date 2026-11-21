import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/load_cubit.dart';
import '../../../core/utils/errors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/shimmer.dart';
import '../../contact/data/contact_repository.dart';
import '../../contact/presentation/widgets/follow_us.dart';
import '../data/content_repository.dart';

/// Header blue from the Terms / Privacy design.
const _headerBlue = Color(0xFF1F7AF0);

/// Privacy policy / terms page: blue rounded header that collapses into a pinned
/// blue app bar on scroll, ordered sections from `privacyPolicy` / `terms`, then a
/// "Follow Us" footer from `socialLinks`.
class ContentPage extends StatefulWidget {
  const ContentPage({super.key, required this.kind});

  /// 'privacy' or 'terms'
  final String kind;

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late Future<ContentDoc> _future = _load();
  ContactLinks? _links;

  bool get _isPrivacy => widget.kind == 'privacy';

  @override
  void initState() {
    super.initState();
    // Footer is optional: a failure just hides it.
    sl<ContactRepository>().fetchLinks().timeout(loadTimeout).then((l) {
      if (mounted) setState(() => _links = l);
    }, onError: (_) {});
  }

  Future<ContentDoc> _load() => sl<ContentRepository>().fetchDoc(widget.kind).timeout(loadTimeout);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: FutureBuilder<ContentDoc>(
          future: _future,
          builder: (context, snap) {
            final loading = snap.connectionState != ConnectionState.done;
            final doc = snap.data;
            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HeaderDelegate(
                    topInset: MediaQuery.paddingOf(context).top,
                    title: context.tr(_isPrivacy ? 'privacy_policy' : 'terms_conditions'),
                    subtitle: context.tr(_isPrivacy ? 'privacy_header_sub' : 'terms_header_sub'),
                    icon: _isPrivacy ? Icons.privacy_tip_outlined : Icons.description_outlined,
                    updatedAt: doc?.updatedAt,
                  ),
                ),
                if (loading)
                  const SliverPadding(padding: EdgeInsets.all(20), sliver: SliverToBoxAdapter(child: ListSkeleton(count: 6)))
                else if (snap.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(
                      errorKey: errorKey(snap.error!),
                      onRetry: () => setState(() {
                        _future = _load();
                      }),
                    ),
                  )
                else if (doc!.sections.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: EmptyState(message: context.tr('no_content')))
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    sliver: SliverList.builder(
                      itemCount: doc.sections.length,
                      itemBuilder: (_, i) => _Section(index: i + 1, section: doc.sections[i]),
                    ),
                  ),
                  if (_links != null)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.paddingOf(context).bottom),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 20),
                            FollowUsSection(links: _links!, inline: true),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Expanded: back + title, icon tile, subtitle, last-updated, rounded bottom.
/// Collapsed: a square blue bar with back + title only.
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({
    required this.topInset,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.updatedAt,
  });

  final double topInset;
  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime? updatedAt;

  static const _bar = 64.0;
  static const _details = 104.0;

  @override
  double get minExtent => topInset + _bar;

  @override
  double get maxExtent => topInset + _bar + _details;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final detailsOpacity = math.max(0.0, 1 - t * 1.8);

    return Container(
      decoration: BoxDecoration(
        color: _headerBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28 * (1 - t))),
      ),
      padding: EdgeInsets.only(top: topInset),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: _bar,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    icon: const BackButtonIcon(),
                    color: Colors.white,
                    onPressed: () => context.canPop() ? context.pop() : Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
            if (detailsOpacity > 0)
              PositionedDirectional(
                start: 18,
                end: 20,
                top: _bar - shrinkOffset * 0.5,
                child: Opacity(
                  opacity: detailsOpacity,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8), height: 1.4),
                            ),
                            if (updatedAt != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${context.tr('last_updated')}: ${DateFormat.yMMMd(locale).format(updatedAt!)}',
                                style: text.bodySmall?.copyWith(color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_HeaderDelegate old) =>
      old.topInset != topInset ||
      old.title != title ||
      old.subtitle != subtitle ||
      old.icon != icon ||
      old.updatedAt != updatedAt;
}

class _Section extends StatelessWidget {
  const _Section({required this.index, required this.section});

  final int index;
  final ContentSection section;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. ${section.title.trim()}',
            style: text.titleMedium?.copyWith(
              color: dark ? const Color(0xFF7DB2FF) : const Color(0xFF1F6FE0),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(section.body.trim(), style: text.bodyLarge?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
