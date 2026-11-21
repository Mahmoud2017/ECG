import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/errors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import '../../profile/presentation/profile_cubit.dart';
import '../data/contact_repository.dart';
import 'widgets/follow_us.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _repo = sl<ContactRepository>();
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  ContactLinks _links = const ContactLinks();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _prefillSender();
    _loadLinks();
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefillSender() {
    final p = sl<ProfileCubit>().state.data;
    _fillIfEmpty(_name, p?.fullName);
    _fillIfEmpty(_email, p?.email);
  }

  void _fillIfEmpty(TextEditingController c, String? value) {
    if (c.text.isEmpty && value != null) c.text = value;
  }

  Future<void> _loadLinks() async {
    try {
      final links = await _repo.fetchLinks();
      if (mounted) setState(() => _links = links);
    } catch (_) {
      // Links are optional.
    }
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await _repo.sendMessage(name: _name.text, email: _email.text, message: _message.text);
      if (!mounted) return;
      _message.clear();
      showSnack(context, 'message_sent');
    } catch (e) {
      if (mounted) showSnack(context, errorKey(e), error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final blue = pageTitleColor(context);
    final l = _links;
    final whatsDigits = l.whatsApp?.replaceAll(RegExp(r'[^0-9]'), '');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TitleAppBar(title: context.tr('contact_us')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Row(
            children: [
              Container(width: 26, height: 3, decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text(context.tr('get_in_touch'), style: text.titleSmall?.copyWith(color: blue, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          Text(context.tr('contact_subtitle'), style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor, height: 1.5)),
          const SizedBox(height: 20),
          if (l.email != null)
            _ContactRow(
              icon: const Icon(Icons.mail_outline_rounded, color: AppColors.brand),
              label: context.tr('email'),
              value: l.email!,
              uri: Uri(scheme: 'mailto', path: l.email),
            ),
          if (l.phone != null)
            _ContactRow(
              icon: const Icon(Icons.phone_outlined, color: AppColors.brand),
              label: context.tr('phone'),
              value: l.phone!,
              uri: Uri(scheme: 'tel', path: l.phone),
            ),
          if (whatsDigits != null && whatsDigits.isNotEmpty)
            _ContactRow(
              icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.brand, size: 22),
              label: context.tr('whatsapp'),
              value: l.whatsApp!,
              uri: Uri.parse('https://wa.me/$whatsDigits'),
            ),
          const SizedBox(height: 8),
          FollowUsSection(links: l, inline: true),
          const SizedBox(height: 24),
          OutlinedCard(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.tr('send_message'), style: text.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  AppTextField(controller: _name, label: context.tr('full_name'), validator: Validators.name),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _email,
                    label: context.tr('email_address'),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _message,
                    label: context.tr('message'),
                    hint: context.tr('message_hint'),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    validator: Validators.message,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: context.tr('send_message_btn'),
                    icon: Icons.send_outlined,
                    loading: _sending,
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Outlined row: light-blue icon tile, label, muted value, chevron.
class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label, required this.value, required this.uri});

  final Widget icon;
  final String label;
  final String value;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: OutlinedCard(
        padding: const EdgeInsets.all(16),
        onTap: () async {
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!ok && context.mounted) showSnack(context, 'error_open_link', error: true);
        },
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}
