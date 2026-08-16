import 'package:flutter/material.dart';

import '../ones/play.dart';
import '../ones/rules.dart';
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
      final p = play.exponent, row = play.row;
      final String tale;
      if (play.rowIsPrime) {
        tale = 'prime, by trial division and by the Lucas-Lehmer chain${play.level.kind == 'perfect' ? ', and ${Rules.commas(BigInt.one << (p - 1))} times it is ${Rules.commas(Rules.perfect(p))}, whose divisors below it add back to it' : ''}';
      } else {
        tale = '${Rules.commas(play.factor)} times ${Rules.commas(row ~/ play.factor)}, so not prime, ${play.exponentIsPrime ? 'though $p is' : 'as $p is ${Rules.smallestExponentFactor(p)} times ${p ~/ Rules.smallestExponentFactor(p)}'}';
      }
      words = '$p ones are ${Rules.commas(row)}: $tale; '
          'one of ${play.level.ways} exponent${play.level.ways == 1 ? '' : 's'} of the ${Rules.settings}; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No composite length gives a prime row. It never will: if the length is a times b, the row of '
          'a ones divides the row of a times b ones, since 2 to the ab less 1 is 2 to the a less 1 times a '
          'sum of powers; four ones, 15, are 3 times 5, and nine ones, 511, are 7 times 73, and every '
          'composite length on the dial from 4 to 30 shows the row of its smallest prime factor as a factor.';
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
              done ? 'Told.' : 'A shorter row divides.',
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
