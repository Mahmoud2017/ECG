import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

void showSnack(BuildContext context, String keyOrText, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(context.tr(keyOrText)),
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
    ));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/empty_folder.png', height: 120),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

enum _ErrorKind { offline, server, generic }

/// Full-area error state. For network errors it checks whether the device is online,
/// so it can say "You're offline" vs "Can't reach the server" truthfully.
class ErrorView extends StatefulWidget {
  const ErrorView({super.key, required this.errorKey, required this.onRetry});

  /// l10n key from [errorKey()] (or a raw message for auth errors).
  final String errorKey;
  final FutureOr<void> Function() onRetry;

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  late _ErrorKind _kind = _initialKind;
  bool _retrying = false;

  _ErrorKind get _initialKind =>
      widget.errorKey == 'error_network' ? _ErrorKind.offline : _ErrorKind.generic;

  @override
  void initState() {
    super.initState();
    _classify();
  }

  @override
  void didUpdateWidget(ErrorView old) {
    super.didUpdateWidget(old);
    if (old.errorKey != widget.errorKey) {
      _kind = _initialKind;
      _classify();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _classify() async {
    if (widget.errorKey != 'error_network') return;
    final online = await _hasInternet();
    if (mounted) setState(() => _kind = online ? _ErrorKind.server : _ErrorKind.offline);
  }

  static Future<bool> _hasInternet() async {
    // Any one resolving means the device is online (some networks block a given resolver/host).
    const hosts = ['google.com', 'cloudflare.com', 'one.one.one.one'];
    for (final host in hosts) {
      try {
        final r = await InternetAddress.lookup(host).timeout(const Duration(seconds: 3));
        if (r.isNotEmpty && r.first.rawAddress.isNotEmpty) return true;
      } catch (_) {
        // try the next host
      }
    }
    return false;
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      // Keep the spinner visible briefly so a fast failure doesn't look like a dead button.
      await Future.wait([Future.sync(widget.onRetry), Future<void>.delayed(const Duration(milliseconds: 700))]);
    } catch (_) {
      // The parent shows the new error state.
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (icon, colors, titleKey, bodyKey) = switch (_kind) {
      _ErrorKind.offline => (
          Icons.wifi_off_rounded,
          const [AppColors.primaryLight, AppColors.primary],
          'offline_title',
          'offline_body',
        ),
      _ErrorKind.server => (
          Icons.cloud_off_rounded,
          const [AppColors.primaryLight, AppColors.primary],
          'server_title',
          'server_body',
        ),
      _ErrorKind.generic => (
          Icons.error_outline_rounded,
          const [Color(0xFFF87171), AppColors.danger],
          'error_title',
          widget.errorKey == 'error_generic' ? 'error_generic_body' : widget.errorKey,
        ),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_kind),
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingBadge(animation: _pulse, icon: icon, colors: colors),
                const SizedBox(height: 28),
                Text(
                  context.tr(titleKey),
                  textAlign: TextAlign.center,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(bodyKey),
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor, height: 1.5),
                ),
                if (_kind == _ErrorKind.offline) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TipChip(icon: Icons.wifi_rounded, label: context.tr('tip_wifi')),
                      _TipChip(icon: Icons.signal_cellular_alt_rounded, label: context.tr('tip_data')),
                      _TipChip(icon: Icons.airplanemode_inactive_rounded, label: context.tr('tip_airplane')),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: AppButton(
                    label: context.tr('try_again'),
                    icon: Icons.refresh_rounded,
                    loading: _retrying,
                    onPressed: _retry,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingBadge extends StatelessWidget {
  const _PulsingBadge({required this.animation, required this.icon, required this.colors});

  final Animation<double> animation;
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            for (final offset in const [0.0, 0.5])
              Builder(builder: (_) {
                final t = (animation.value + offset) % 1.0;
                return Container(
                  width: 96 + 72 * t,
                  height: 96 + 72 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.last.withValues(alpha: 0.16 * (1 - t)),
                  ),
                );
              }),
            child!,
          ],
        ),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: colors.last.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: Icon(icon, color: Colors.white, size: 44),
        ),
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
        if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: Text(context.tr('see_all'))),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}
