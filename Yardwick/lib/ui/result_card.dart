import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
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
      words = 'Counts ${play.first} and ${play.second}, hedges ${Rules.tell(play.firstHedge)} and ${Rules.tell(play.secondHedge)}: '
          'the yardstick ${Rules.tell(play.measure)}, by Euclid on the hedges and by the counts, which measure by ${play.commonCount}'
          '${play.firstMeasuresSecond ? ', the first hedge measuring the second exactly' : ''}; '
          'one of ${level.ways} setting${level.ways == 1 ? '' : 's'} of the 900; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No two hedges share a factor their counts do not. They never will: two Fibonacci numbers share exactly '
          'the factors their counts share, since the (m + n)th is the (m - 1)th times the nth plus the mth times the '
          '(n + 1)th, and Euclid runs on the counts as it runs on the hedges, down to the first hedge, one, when the '
          'counts share nothing; the sweep of all 900 settings finds the yardstick by both roads agreeing on every one.'
          ' Here the counts ${play.first} and ${play.second} measure by ${play.commonCount}, and the yardstick is ${Rules.tell(play.measure)}.';
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
              done ? 'Measured.' : 'As the counts go, always.',
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
