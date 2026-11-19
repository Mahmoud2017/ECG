import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/data/profile.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.profile, this.radius = 32});

  final Profile? profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = profile?.avatarUrl;
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.gradient),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
        child: Text(
          profile?.initials ?? '',
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
