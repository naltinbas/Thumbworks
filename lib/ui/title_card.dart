import 'package:flutter/widgets.dart';

import '../best_run.dart';
import 'chrome.dart';
import 'palette.dart';

/// The screen the game opens on, over a craft already swinging round the first
/// well.
///
/// There is no menu because there is nothing to choose. The only thing a
/// player can do here is start, so the whole screen does it.
class TitleCard extends StatelessWidget {
  const TitleCard({super.key, required this.best, required this.onStart});

  final BestRun best;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onStart,
      child: Scrim(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Slingwell',
                  style: TextStyle(
                    color: Palette.ink,
                    fontSize: 44,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 9,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Swing the well. Let go at the right moment.\n'
                  'Catch the next one and climb.',
                  textAlign: TextAlign.center,
                  style: noteStyle,
                ),
                const SizedBox(height: 34),
                Text(
                  bestLine(best),
                  style: best.hasRun
                      ? labelStyle.copyWith(color: Palette.wellHeld)
                      : labelStyle,
                ),
                const SizedBox(height: 44),
                const _Prompt(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Says what to do, and breathes so the eye finds it.
class _Prompt extends StatefulWidget {
  const _Prompt();

  @override
  State<_Prompt> createState() => _PromptState();
}

class _PromptState extends State<_Prompt> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween<double>(begin: 0.4, end: 1).animate(
          CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
        ),
        child: const Text(
          'Tap to fly',
          style: TextStyle(
            color: Palette.craft,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
          ),
        ),
      );
}
