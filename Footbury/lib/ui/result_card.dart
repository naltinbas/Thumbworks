import 'package:flutter/material.dart';

import '../foot/frac.dart';
import '../foot/play.dart';
import '../foot/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onSham,
  });

  final Play play;

  /// The standing record, after this setting counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      words = 'Triangle ${cornerWords(play)} with the point ${Rules.tellPeg(play.point!)}: feet at ${feetWords(play)}, '
          '${play.line != null ? 'in a line' : 'their triangle ${shareWords(play.ratio!)} of the whole'}, by the feet and by Euler\'s rule; '
          'one of ${_commas(level.ways)} setting${level.ways == 1 ? '' : 's'} of the 25,960; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final r = play.ratio;
      words = 'No point off the rim drops its feet in a line. It never will: the feet\'s triangle is to the whole as the '
          'square of the radius less the square of the point\'s distance from the middle is to four times the square of '
          'the radius, so it shrinks to nothing exactly when the point stands a radius from the middle, on the rim; the '
          'sweep of all 25,960 settings finds the feet in a line on the 1,980 rim settings and on none of the others.'
          '${r == null || play.pointOnRim ? '' : ' Here the point ${Rules.tellPeg(play.point!)} stands root ${Rules.distanceSquared(play.point!)} from the middle, and its feet make ${shareWords(r)} of the whole.'}';
    }
    return Card(
      color: Palette.board,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: done ? Palette.good : Palette.bad, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              done ? 'Footed.' : 'On the rim alone, always.',
              style: TextStyle(
                color: done ? Palette.good : Palette.bad,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(words,
                style:
                    const TextStyle(color: Palette.ink, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: onAgain,
                  child: const Text('Again'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: onSham,
                  child: const Text('The sham'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The corners in words: '(5, 0), (-4, 3), (-3, -4)'.
String cornerWords(Play play) => play.corners.map(Rules.tellPeg).join(', ');

/// The feet in words: '(-21/5, 22/5), (3, -1), (-1, 2)'.
String feetWords(Play play) => play.feet!.map(Rules.tellPoint).join(', ');

/// A share in words: '1/5', 'nought', 'minus 1/4'.
String shareWords(Frac r) => r == Frac.zero ? 'nought' : r.n.isNegative ? 'minus ${r.n.abs()}/${r.d}' : '$r';

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
