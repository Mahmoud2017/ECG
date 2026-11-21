import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../data/contact_repository.dart';

/// Base URLs recovered from the binary.
String? _socialUrl(String base, String? handle) {
  if (handle == null || handle.isEmpty) return null;
  return handle.startsWith('http') ? handle : '$base$handle';
}

class FollowUsSection extends StatefulWidget {
  const FollowUsSection({super.key, required this.links, this.inline = false});

  final ContactLinks links;

  /// Footer style: "Follow Us" on the left, outlined square icons on the right.
  final bool inline;

  @override
  State<FollowUsSection> createState() => _FollowUsSectionState();
}

class _FollowUsSectionState extends State<FollowUsSection> {
  Future<void> _open(String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) showSnack(context, 'error_open_link', error: true);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.links;
    final items = <(FaIconData, Color, String?)>[
      (FontAwesomeIcons.whatsapp, const Color(0xFF25D366), _socialUrl('https://wa.me/', l.whatsApp?.replaceAll(RegExp(r'[^0-9]'), ''))),
      (FontAwesomeIcons.facebookF, const Color(0xFF1877F2), _socialUrl('https://facebook.com/', l.faceBook)),
      (FontAwesomeIcons.instagram, const Color(0xFFE4405F), _socialUrl('https://instagram.com/', l.instagram)),
      (FontAwesomeIcons.linkedinIn, const Color(0xFF0A66C2), _socialUrl('https://www.linkedin.com/in/', l.linkedIn)),
      (FontAwesomeIcons.xTwitter, Colors.black, _socialUrl('https://x.com/', l.twitter)),
    ].where((e) => e.$3 != null).toList();

    if (items.isEmpty) return const SizedBox.shrink();
    if (widget.inline) {
      final dark = Theme.of(context).brightness == Brightness.dark;
      return Row(
        children: [
          Expanded(
            child: Text(
              context.tr('follow_us'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          for (final i in items) ...[
            const SizedBox(width: 12),
            _SquareButton(icon: i.$1, color: dark ? Colors.white : AppColors.navy, onTap: () => _open(i.$3!)),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('follow_us'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [for (final i in items) _SocialButton(icon: i.$1, color: i.$2, onTap: () => _open(i.$3!))],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.color, required this.onTap});

  final FaIconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.12),
          child: FaIcon(icon, color: color, size: 20),
        ),
      );
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.color, required this.onTap});

  final FaIconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: dark ? Colors.white24 : AppColors.fieldBorder),
    );
    return Material(
      color: Colors.transparent,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: SizedBox(width: 52, height: 52, child: Center(child: FaIcon(icon, color: color, size: 22))),
      ),
    );
  }
}
