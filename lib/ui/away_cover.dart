import 'package:flutter/material.dart';

import 'hud.dart';
import 'palette.dart';

/// Over the puzzle while the app is away, and until the player says they are
/// back.
///
/// The clock stops when the game goes off screen, because a puzzle put down at
/// a bus stop is not a puzzle that took forty minutes and the times are worth
/// keeping honest. But a stopped clock over a puzzle that can still be read is
/// just as dishonest the other way: the numbers are all on the screen, and
/// thinking is the entire game. So the puzzle goes away with the clock, and
/// comes back with it.
///
/// Solid rather than a wash, because a grid of two digit numbers is perfectly
/// legible through a dark tint.
class AwayCover extends StatelessWidget {
  const AwayCover({super.key, required this.elapsed, required this.onResume});

  /// What the clock is holding at, which is the thing a player coming back
  /// wants to see is unchanged.
  final Duration elapsed;

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Semantics(
        button: true,
        label: 'Paused. Tap to carry on with the puzzle.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onResume,
          child: ColoredBox(
            color: Palette.paper,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Paused',
                    style: TextStyle(
                      color: Palette.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The clock stopped when you left.',
                    style: TextStyle(color: Palette.inkDim, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${PuzzleBar.face(elapsed)} so far',
                    style: const TextStyle(
                      color: Palette.ink,
                      fontSize: 17,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Tap to carry on',
                    style: TextStyle(
                      color: Palette.good,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
