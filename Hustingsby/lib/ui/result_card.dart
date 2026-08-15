import 'package:flutter/material.dart';

import '../poll/play.dart';
import '../poll/rules.dart';
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

  /// The standing record, after this count counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      words = 'Counted ${Rules.told(play.drawn)}: level ${play.levelsSoFar} time${play.levelsSoFar == 1 ? '' : 's'}, the lead changed hands '
          '${play.changesSoFar} time${play.changesSoFar == 1 ? '' : 's'}, Ash ${play.aheadSoFar ? 'ahead throughout' : play.neverBehindSoFar ? 'never behind' : 'behind at some point'}; '
          'one of ${play.level.ways} orders of ${play.level.orders.length} that land it; ${play.moves} draw${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No order of a level poll keeps Ash ahead after every ballot. It never will: the '
          'poll ends level, so the last ballot lands the count on the level line whatever went '
          'before; this order ends ${Rules.told(play.drawn)}, and the sweep of all 70 orders of '
          'four to four finds every one level at the end, Bertrand\'s majority of nought over the '
          'poll saying nought.';
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
              done ? 'Counted.' : 'Level at the end, always.',
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
