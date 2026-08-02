/// The small pieces of type and shape the screens around the board share, so
/// the score, the clock and the end of a round are set the same way.
library;

import 'package:flutter/widgets.dart';

import '../game/board.dart';
import 'palette.dart';

/// A sentence about the game, in the size the game talks in.
const noteStyle = TextStyle(color: Palette.inkDim, fontSize: 15, height: 1.4);

/// A word under a number, or a line that is not asking to be read first.
const labelStyle = TextStyle(
  color: Palette.inkDim,
  fontSize: 13,
  fontWeight: FontWeight.w500,
  letterSpacing: 1.4,
);

/// A number with a word under it: the score, the clock, a count.
///
/// The number is set in tabular figures so a score going from 9 to 10, or a
/// clock counting down, does not shuffle everything beside it sideways.
class Readout extends StatelessWidget {
  const Readout({
    super.key,
    required this.value,
    required this.label,
    required this.tone,
    this.size = 40,
    this.align = CrossAxisAlignment.start,
  });

  final String value;
  final String label;
  final Color tone;
  final double size;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        Text(
          value,
          maxLines: 1,
          style: TextStyle(
            color: tone,
            fontSize: size,
            fontWeight: FontWeight.w300,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, maxLines: 1, style: labelStyle),
      ],
    );
  }
}

/// One word, and what it was worth.
///
/// The same shape wherever a word appears, so the list running under the
/// board and the two lists at the end of the round are plainly the same
/// thing.
class WordChip extends StatelessWidget {
  const WordChip({super.key, required this.word, this.tone = Palette.word});

  final String word;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    // Shrunk whole rather than allowed to run off the side of the screen. A
    // nine letter word at a large system text setting is wider than a small
    // phone, and the one thing a list of words cannot do is hide the end of
    // one. Nothing happens to a chip that already fits.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: tone.withValues(alpha: 0.34)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              word.toUpperCase(),
              style: TextStyle(
                color: tone,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                height: 1,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              '${Board.scoreOf(word)}',
              style: TextStyle(
                color: tone.withValues(alpha: 0.65),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the title screen and the end of a round say about the best score.
String bestLine(int points, int? seed) {
  if (points <= 0) return 'no round finished yet';
  return seed == null ? 'best $points' : 'best $points on seed $seed';
}
