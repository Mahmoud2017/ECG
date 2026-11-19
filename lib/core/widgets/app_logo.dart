import 'package:material_ui/material_ui.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 48, this.markOnly = false});

  final double height;
  final bool markOnly;

  @override
  Widget build(BuildContext context) {
    if (markOnly) {
      return Image.asset('assets/images/app_icon_foreground.png', height: height);
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      dark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
