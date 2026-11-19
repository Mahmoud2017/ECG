import 'package:material_ui/material_ui.dart';

/// Lightweight shimmer (recovered: _ShimmerState, _SlideGradient).
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF1E293B) : const Color(0xFFE5E9F2);
    final highlight = dark ? const Color(0xFF334155) : const Color(0xFFF5F7FB);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.1, 0.3, 0.4],
          begin: const Alignment(-1, -0.3),
          end: const Alignment(1, 0.3),
          transform: _SlideGradient(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.percent);

  final double percent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (percent * 2 - 1), 0, 0);
}

/// Grey placeholder box used inside [Shimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.radius = 12});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
      );
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) => Shimmer(
        child: Column(
          children: List.generate(
            count,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonBox(height: 72, radius: 18),
            ),
          ),
        ),
      );
}
