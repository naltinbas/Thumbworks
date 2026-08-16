import 'package:flutter/material.dart';

import '../turn/play.dart';
import '../turn/rules.dart';
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

  /// The standing record, after this fraction counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final digits = play.digits;
      final block = Rules.tellDigits(digits);
      words = '${play.top} over ${play.prime} is 0.$block repeating, ${digits.length} place${digits.length == 1 ? '' : 's'}: '
          'the remainders run ${play.remainders.join(', ')} and come round, and $block times ${play.prime} is ${Rules.commas(Rules.nines(digits.length) * BigInt.from(play.top))}; '
          'one of ${play.level.ways} fraction${play.level.ways == 1 ? '' : 's'} of the ${Rules.settings}; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No decimal over a prime takes more than p - 1 places to come round. It never will: the '
          'remainders are the hours 1 to p - 1, never 0, so within p - 1 steps one comes again and the '
          'digits repeat from there; ${play.top} over ${play.prime} takes the whole ${play.prime - 1}, '
          'the longest there is, and the sweep of all ${Rules.settings} fractions on the dial finds none longer.';
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
              done ? 'Come round.' : 'The whole turn at most.',
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
