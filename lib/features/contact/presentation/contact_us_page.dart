import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('contact_us'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(context.tr('get_in_touch'), style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(context.tr('contact_subtitle'), style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
          const SizedBox(height: 16),
          if (_links.phone != null || _links.email != null)
            Row(
              children: [
                if (_links.phone != null)
                  Expanded(
                    child: _ContactCard(
                      icon: Icons.phone_rounded,
                      label: context.tr('phone'),
                      value: _links.phone!,
                      uri: Uri(scheme: 'tel', path: _links.phone),
                    ),
                  ),
                if (_links.phone != null && _links.email != null) const SizedBox(width: 12),
                if (_links.email != null)
                  Expanded(
                    child: _ContactCard(
                      icon: Icons.mail_rounded,
                      label: context.tr('email'),
                      value: _links.email!,
                      uri: Uri(scheme: 'mailto', path: _links.email),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 20),
          AppCard(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.tr('send_message'), style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  AppTextField(controller: _name, label: context.tr('full_name'), validator: Validators.name),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _email,
                    label: context.tr('email_address'),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _message,
                    label: context.tr('message'),
                    hint: context.tr('message_hint'),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    validator: Validators.message,
                  ),
                  const SizedBox(height: 16),
                  AppButton(label: context.tr('send_message_btn'), loading: _sending, onPressed: _send),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FollowUsSection(links: _links),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.icon, required this.label, required this.value, required this.uri});

  final IconData icon;
  final String label;
  final String value;
  final Uri uri;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: () async {
          final ok = await launchUrl(uri);
          if (!ok && context.mounted) showSnack(context, 'error_open_link', error: true);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr),
          ],
        ),
      );
}
