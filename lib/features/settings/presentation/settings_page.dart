import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/state/load_cubit.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../../history/presentation/patients_cubit.dart';
import '../../profile/data/profile.dart';
import '../../profile/presentation/profile_cubit.dart';
import 'settings_cubit.dart';
import 'widgets/language_sheet.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/profile_avatar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>();
    if (profile.state.data == null) profile.load();
  }

  Future<void> _pickLanguage() async {
    final settings = context.read<SettingsCubit>();
    final code = await showLanguageSheet(context, settings.state.locale.languageCode);
    if (code != null) settings.setLocale(code);
  }

  Future<void> _editLocation(Profile? profile) async {
    final controller = TextEditingController(text: profile?.location ?? '');
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: controller,
              label: ctx.tr('location'),
              hint: ctx.tr('location_hint'),
              prefixIcon: Icons.location_on_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            AppButton(label: ctx.tr('save'), onPressed: () => Navigator.pop(ctx, controller.text.trim())),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    final error = await context.read<ProfileCubit>().updateLocation(value);
    if (error != null && mounted) showSnack(context, error, error: true);
  }

  Future<void> _logout() async {
    if (!await showLogoutDialog(context) || !mounted) return;
    context.read<ProfileCubit>().clear();
    sl<PatientsCubit>().clear();
    await context.read<AuthCubit>().signOut();
    if (mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: TitleAppBar(title: context.tr('nav_settings'), onBack: () => context.go(Routes.home)),
      body: BlocBuilder<ProfileCubit, LoadState<Profile>>(
        builder: (context, state) {
          final p = state.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              OutlinedCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ProfileAvatar(profile: p),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p?.fullName ?? '—', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          if ((p?.jobTitle ?? p?.specialty) != null)
                            Text((p!.jobTitle ?? p.specialty)!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                          if (p?.email != null) Text(p!.email!, style: Theme.of(context).textTheme.bodySmall),
                          if (p?.phoneNumber != null)
                            Text(p!.phoneNumber!, textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Group(children: [
                _SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: context.tr('location'),
                  value: (p?.location?.isNotEmpty ?? false) ? p!.location! : context.tr('not_set'),
                  onTap: () => _editLocation(p),
                ),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: context.tr('language'),
                  value: context.tr(settings.locale.languageCode == 'ar' ? 'lang_ar' : 'lang_en'),
                  onTap: _pickLanguage,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(context.tr('dark_mode')),
                  value: settings.darkMode,
                  onChanged: context.read<SettingsCubit>().setDarkMode,
                ),
              ]),
              const SizedBox(height: 16),
              _Group(children: [
                _SettingsTile(icon: Icons.help_outline_rounded, title: context.tr('help'), onTap: () => context.push(Routes.help)),
              ]),
              const SizedBox(height: 16),
              _Group(children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: context.tr('log_out'),
                  destructive: true,
                  onTap: _logout,
                ),
              ]),
            ],
          );
        },
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => OutlinedCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: children),
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(value!, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
            ),
          if (!destructive) const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
