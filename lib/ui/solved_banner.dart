import 'package:flutter/material.dart';

import 'palette.dart';

/// What a finished level says for itself.
///
/// It rises over the bottom of the screen rather than covering it, so the lit
/// board the player just made stays in view: the board is the reward and this
/// is only the part of it that can be tapped.
class SolvedBanner extends StatelessWidget {
  const SolvedBanner({
    super.key,
    required this.level,
    required this.moves,
    required this.bestBefore,
    required this.rise,
    required this.onNext,
    required this.onReplay,
  });

  final int level;
  final int moves;

  /// The best this level had been solved in before this attempt, or null if
  /// this was the first time. Read from before the win so the banner can tell
  /// the player they beat it.
  final int? bestBefore;

  /// Drives the whole thing on, 0 to 1.
  final Animation<double> rise;

  final VoidCallback onNext;
  final VoidCallback onReplay;

  bool get _isBest => bestBefore == null || moves < bestBefore!;

  String get _line {
    final count = moves == 1 ? '1 move' : '$moves moves';
    if (bestBefore == null) return count;
    return _isBest ? '$count, a new best' : '$count, best $bestBefore';
  }

  @override
  Widget build(BuildContext context) {
    // Driven rather than curved, so there is no animation object here to own
    // and dispose in a widget that has no state.
    final eased = rise.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: eased,
      child: SlideTransition(
        position: eased.drive(
          Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
          decoration: const BoxDecoration(
            color: Palette.panel,
            border: Border(top: BorderSide(color: Palette.accent, width: 2)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          // Scrolls only when the screen is too short to show the whole
          // reward, which no phone held upright is. It is here so that when
          // that does happen the buttons can still be reached, rather than
          // being clipped off the bottom.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level $level solved',
                  style: const TextStyle(
                    color: Palette.accent,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _line,
                  style: const TextStyle(color: Palette.inkDim, fontSize: 15),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: onNext,
                  child: const Text('Next level'),
                ),
                TextButton(
                  onPressed: onReplay,
                  child: const Text('Play it again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
