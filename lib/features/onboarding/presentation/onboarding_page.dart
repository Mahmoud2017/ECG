import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/shimmer.dart';
import '../data/onboarding_repository.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _repo = sl<OnboardingRepository>();
  final _controller = PageController();
  int _index = 0;
  bool _ready = false;

  List<OnboardingSlide> get _slides => _repo.slides;
  bool get _isLast => _index == _slides.length - 1;

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _fadeInAfterShimmer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fadeInAfterShimmer() async {
    // Let images decode behind a skeleton, then fade in.
    await Future.wait([for (final s in _slides) precacheImage(AssetImage(s.icon), context)]);
    if (mounted) setState(() => _ready = true);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  Future<void> _finish() async {
    await _repo.markSeen();
    if (mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AnimatedOpacity(
                  opacity: _isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(onPressed: _isLast ? null : _finish, child: Text(context.tr('skip'))),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _ready ? _Slide(slide: _slides[i]) : const _SlideSkeleton(),
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: _slides.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 28),
              AppButton(label: context.tr(_isLast ? 'get_started' : 'next'), onPressed: _next),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(slide.icon, height: 240),
        const SizedBox(height: 32),
        Text(
          context.tr(slide.titleKey),
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          context.tr(slide.bodyKey),
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

class _SlideSkeleton extends StatelessWidget {
  const _SlideSkeleton();

  @override
  Widget build(BuildContext context) => const Shimmer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonBox(width: 240, height: 240, radius: 120),
            SizedBox(height: 32),
            SkeletonBox(width: 260, height: 22),
            SizedBox(height: 12),
            SkeletonBox(width: 300, height: 14),
            SizedBox(height: 8),
            SkeletonBox(width: 220, height: 14),
          ],
        ),
      );
}
