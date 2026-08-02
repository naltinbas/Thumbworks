import 'package:flutter/material.dart';

import 'palette.dart';

/// Covers the board while the round is paused, because the app went away.
///
/// The cover is the honest half of pausing. Stopping the clock alone would let
/// a player leave the game, study the letters with all the time in the world,
/// and come back to a round they have already solved. Hiding the board while
/// the clock is stopped means the pause costs them nothing and gives them
/// nothing, which is the only version of pausing worth having.
///
/// So this is opaque rather than a dark wash. Letters on a near-black board
/// under a ninety-per-cent scrim are still letters, and a cover that can be
/// read through is not a cover. What it does show is where the round stands,
/// because the thing a player wants to know coming back to a game they left
/// is that the round is still theirs.
class AwayCover extends StatelessWidget {
  const AwayCover({
    super.key,
    required this.onResume,
    required this.score,
    required this.found,
    required this.left,
  });

  final VoidCallback onResume;

  /// What the round is worth so far.
  final int score;

  /// How many words are in it.
  final int found;

  /// How much of the round is still to play.
  final Duration left;

  static String _face(Duration left) {
    final seconds = (left.inMilliseconds / 1000).ceil();
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Semantics(
        button: true,
        label: 'Paused. Tap to carry on with the round.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onResume,
          child: ColoredBox(
            color: Palette.blind,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Paused',
                    style: TextStyle(
                      color: Palette.ink,
                      fontSize: 34,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your clock stopped when you left.',
                    style: TextStyle(color: Palette.inkDim, fontSize: 15),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '$score  ·  $found ${found == 1 ? 'word' : 'words'}'
                    '  ·  ${_face(left)} left',
                    style: TextStyle(
                      color: Palette.ink,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Tap to carry on',
                    style: TextStyle(
                      color: Palette.word,
                      fontSize: 18,
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
