import 'package:flutter/material.dart';

import '../train/play.dart';
import '../train/rules.dart';
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

  /// The standing record, after this train counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final (way, _) = play.turning;
    final String words;
    if (done) {
      final String what;
      if (play.level.hasMill) {
        final (n, d) = Rules.speed(play.gears[0], play.gears[1]);
        what = 'The mill turns ${way[1] > 0 ? 'with' : 'against'} the crank, ${play.gears.length - 1} mesh${play.gears.length - 1 == 1 ? '' : 'es'} on, '
            '${d == 1 ? '$n turn${n == 1 ? '' : 's'}' : '$n/$d of a turn'} for every turn of it, the crank\'s ${play.gears[0].$3} over the mill\'s ${play.gears[1].$3}';
      } else {
        what = 'The ring of ${play.gears.length} turns, ${way.where((w) => w > 0).length} gears with the crank and ${way.where((w) => w < 0).length} against';
      }
      words = '$what; ${play.moves} placing${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The ring of three jams. It always will: every mesh turns the next gear the '
          'other way, so round a ring the ways go with, against, with, against, and a ring '
          'of three comes back to the crank asking it to turn against itself; only rings '
          'with an even count of gears turn.';
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
              done ? 'Geared.' : 'The odd ring jams.',
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
