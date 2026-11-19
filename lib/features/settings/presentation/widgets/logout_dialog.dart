import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/app_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) => showAppDialog(
      context,
      title: context.tr('log_out'),
      message: context.tr('log_out_confirm'),
      icon: Icons.logout_rounded,
      confirmLabel: context.tr('log_out'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
