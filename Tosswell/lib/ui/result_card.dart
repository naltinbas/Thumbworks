import 'package:flutter/material.dart';

import '../toss/play.dart';
import '../toss/rules.dart';
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

  /// The standing record, after this rule counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      words = 'The rule walks away ahead on ${play.ahead} of the '
          '${Rules.runs} runs, at best ${Rules.tellPurse(play.best)} and at '
          'worst ${Rules.tellPurse(play.worst)}, and the ${Rules.runs} purses '
          'add to nothing, walked run by run and folded backward from the '
          'last row alike; one of ${play.level.ways} '
          '${play.level.ways == 1 ? 'rule' : 'rules'} of the 802 that '
          '${play.level.ways == 1 ? 'lands' : 'land'} it; ${play.moves} '
          'mark${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No rule walks away level or better on every run and ahead on '
          'some. If it never went behind, the 32 purses could only add to '
          'nothing by every one of them being nothing, and any run that '
          'walked away ahead would push the total over. But the total is '
          'always nothing: at every standing the two tosses out of it are '
          'worth one more and one less, so the standing is worth what it '
          'holds, and averaging back from the last row leaves the purse where '
          'it began. This rule walks away ahead on ${play.ahead} runs and '
          'down to ${Rules.tellPurse(play.worst)} at worst, adding to '
          '${play.added}. All 802 rules were walked before the sham was built '
          'and every one of them came to nothing.';
    }
    return Card(
      color: Palette.board,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: done ? Palette.good : Palette.bad, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              done ? 'Walked.' : 'Nothing, whatever you mark.',
              style: TextStyle(
                color: done ? Palette.good : Palette.bad,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(words,
                style: const TextStyle(color: Palette.ink, fontSize: 14)),
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
