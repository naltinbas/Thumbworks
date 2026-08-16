import 'package:flutter/material.dart';

import '../period/play.dart';
import '../period/rules.dart';
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

  /// The standing record, after this tally counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final c = play.cycle;
      final told = c.length <= 12 ? c.join(', ') : '${c.take(8).join(', ')} and on to ${c[c.length - 2]}, ${c.last}';
      words = 'On the ${play.clock}-hour clock the Fibonacci numbers run $told, and then 0, 1 again: period ${play.period}, '
          'the matrix agreeing, and its bound ${Rules.bound(play.clock)}; '
          'one of ${play.level.ways} clock${play.level.ways == 1 ? '' : 's'} of the ${Rules.settings}; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No clock past two has an odd period. It never will: Cassini\'s identity, F(n - 1) F(n + 1) '
          'less F(n) squared is plus or minus one with the sign turning each step, holds on every clock, '
          'and an odd period would make it 1 and -1 at once at the period, which only the two-hour clock '
          'allows; here the ${play.clock}-hour clock has period ${play.period}, even, and the sweep of every clock to two hundred '
          'finds the two-hour clock alone with an odd period, three.';
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
              done ? 'Come round.' : 'Even, by Cassini.',
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
