import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/news_category.dart';
import '../providers/navigation_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/common/app_logo.dart';
import '../widgets/category/interest_picker.dart';

/// First-time screens: 1. Welcome, 2. Choose your interests.
/// Shown once. "Skip" or "Continue" opens the app.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  late final Set<String> _selected;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _selected = context.read<OnboardingProvider>().interests.toSet();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _toggle(String categoryId) {
    setState(() {
      if (!_selected.remove(categoryId)) _selected.add(categoryId);
    });
  }

  /// Saves the picks (or keeps the old ones on Skip) and opens Home.
  void _finish({required bool savePicks}) {
    context.read<NavigationProvider>().goTo(AppTab.home);
    context.read<OnboardingProvider>().finish(
      interests: savePicks ? _selected.toList() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToPage(0);
      },
      child: Scaffold(
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _WelcomePage(
                onStart: () => _goToPage(1),
                onSkip: () => _finish(savePicks: false),
              ),
              _InterestsPage(
                selected: _selected,
                onToggle: _toggle,
                onBack: () => _goToPage(0),
                onSkip: () => _finish(savePicks: false),
                onContinue: () => _finish(savePicks: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 1: logo, slogan, colored category tiles and "Get Started".
class _WelcomePage extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const _WelcomePage({required this.onStart, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        _TopBar(step: 1, onSkip: onSkip),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const AppLogo(fontSize: 40),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text: 'Your World in Brief',
                    children: [
                      TextSpan(
                        text: '.',
                        style: TextStyle(color: colors.primary),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Get the latest news, curated for you.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                const _CategoryMosaic(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _BigButton(label: 'Get Started', onPressed: onStart),
      ],
    );
  }
}

/// Step 2: pick categories. They move to the front of the Home tabs.
class _InterestsPage extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  const _InterestsPage({
    required this.selected,
    required this.onToggle,
    required this.onBack,
    required this.onSkip,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = selected.length;

    return Column(
      children: [
        _TopBar(step: 2, onSkip: onSkip, onBack: onBack),
        const SizedBox(height: 8),
        Text(
          'Choose your interests',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Pick the topics you like. They will show first on Home.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: InterestPicker(selectedIds: selected, onToggle: onToggle),
        ),
        _BigButton(
          label: count == 0 ? 'Continue' : 'Continue ($count selected)',
          onPressed: onContinue,
        ),
      ],
    );
  }
}

/// Back arrow (step 2 only), a 2-part red step bar and "Skip".
class _TopBar extends StatelessWidget {
  final int step;
  final VoidCallback onSkip;
  final VoidCallback? onBack;

  const _TopBar({required this.step, required this.onSkip, this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: onBack == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    onPressed: onBack,
                  ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 1; i <= 2; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= step
                            ? colors.primary
                            : colors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          ),
          TextButton(onPressed: onSkip, child: const Text('Skip')),
        ],
      ),
    );
  }
}

/// One big Sri Lanka tile, then the other categories in 3 columns.
class _CategoryMosaic extends StatelessWidget {
  const _CategoryMosaic();

  @override
  Widget build(BuildContext context) {
    final categories = NewsCategory.choosable;
    final first = categories.first;
    final rest = categories.skip(1).toList();

    return Column(
      children: [
        SizedBox(height: 120, child: _ColorTile(category: first, big: true)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final category in rest) _ColorTile(category: category),
          ],
        ),
      ],
    );
  }
}

/// A rounded tile with the category color, a big faded icon and the name.
class _ColorTile extends StatelessWidget {
  final NewsCategory category;
  final bool big;

  const _ColorTile({required this.category, this.big = false});

  @override
  Widget build(BuildContext context) {
    final color = category.color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.4)!],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              category.icon,
              size: big ? 110 : 56,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: big ? 18 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The wide red button at the bottom, with an arrow.
class _BigButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BigButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}