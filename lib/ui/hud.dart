import 'package:flutter/material.dart';

import '../game/round.dart';
import 'chrome.dart';
import 'palette.dart';

/// The score, the words so far, and how long is left.
///
/// It reads the clock straight off its animation, so the seconds and the bar
/// under them redraw without anything above rebuilding, and a word being
/// traced never waits on this.
class Hud extends StatelessWidget {
  const Hud({
    super.key,
    required this.round,
    required this.clock,
    required this.best,
    required this.onEnd,
  });

  final Round round;

  /// The player is done before the clock is.
  final VoidCallback onEnd;

  /// Nought when the round starts, one when the time is gone.
  final Animation<double> clock;

  /// Points in the best round so far, or zero if there has not been one.
  final int best;

  /// The last stretch, when the clock is worth looking at.
  static const hurry = Duration(seconds: 20);

  /// Nearly gone. The point of this is to be seen out of the corner of an eye
  /// by someone staring at letters.
  static const urgent = Duration(seconds: 10);

  /// How far the system's text setting is followed here.
  ///
  /// These figures are display-sized already, and every square of the board
  /// has to stay big enough for a thumb underneath them. The words that
  /// explain the game are on the title and the end card, which scale the
  /// whole way.
  static const _maxTextScale = 1.3;

  static String _clockFace(Duration left) {
    final seconds = (left.inMilliseconds / 1000).ceil();
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  static Color _tone(Duration left) {
    if (left <= urgent) return Palette.alarm;
    if (left <= hurry) return Palette.stale;
    return Palette.ink;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxTextScale,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        // Only the two things the clock draws are rebuilt on its frames. The
        // score is not one of them, and neither is the button, which would
        // otherwise be rebuilt sixty times a second for two minutes.
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Readout(
                    value: '${round.score}',
                    label: round.found.length == 1
                        ? '1 word'
                        : '${round.found.length} words',
                    tone: Palette.word,
                    size: 38,
                  ),
                ),
                // A way out of a round that is not the Android back
                // button, which iOS has no answer to. It ends the round
                // rather than throwing it away: the player still gets to
                // see what was in the board.
                TextButton(
                  onPressed: onEnd,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                  ),
                  // The label belongs inside the button, so the node a
                  // screen reader can press is the one that says what
                  // pressing it does. Around the button it lands on a node
                  // with no tap on it, and the button is left announcing
                  // itself as a multiplication sign.
                  child: Semantics(
                    label: 'end the round',
                    excludeSemantics: true,
                    child: const Text(
                      '×',
                      style: TextStyle(
                        color: Palette.inkDim,
                        fontSize: 26,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: AnimatedBuilder(
                    animation: clock,
                    builder: (context, _) {
                      final left = round.length * (1 - clock.value);
                      return Readout(
                        value: _clockFace(left),
                        label: best > 0 ? 'best $best' : 'first round',
                        tone: _tone(left),
                        size: 38,
                        align: CrossAxisAlignment.end,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: clock,
              builder: (context, _) {
                final left = round.length * (1 - clock.value);
                return _Fuse(
                  left: 1 - clock.value,
                  // Blue while there is time, which is the colour of a
                  // trace that is only letters so far: nothing is wrong
                  // yet.
                  tone: left > hurry ? Palette.trace : _tone(left),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The time left as a line across the top of the game.
///
/// A player deep in a board does not read a clock, but they see a line
/// getting shorter, and it is the width of the screen away from the letters
/// they are staring at.
class _Fuse extends StatelessWidget {
  const _Fuse({required this.left, required this.tone});

  /// One at the start of the round, nought at the end.
  final double left;

  final Color tone;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: Stack(
          children: [
            const ColoredBox(color: Palette.tileEdge, child: SizedBox.expand()),
            FractionallySizedBox(
              widthFactor: left.clamp(0.0, 1.0),
              child: ColoredBox(color: tone, child: const SizedBox.expand()),
            ),
          ],
        ),
      ),
    );
  }
}
