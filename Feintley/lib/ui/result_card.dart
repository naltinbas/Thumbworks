import 'package:flutter/material.dart';

import '../feint/play.dart';
import '../feint/rules.dart';
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
      words = '${play.number} on base ${play.base}: ${madeOf(play)}, the base raised to ${play.number - 1} lands on ${play.landing}, '
          '${play.passes ? 'so it passes' : 'so it fails'}, by squaring and by the whole power brought down'
          '${play.liar ? ', and it is lying: a composite passing the test' : ''}'
          '${play.carmichael ? ', on every base it shares no factor with' : ''}; '
          'one of ${Rules.tell(level.ways)} setting${level.ways == 1 ? '' : 's'} of the 13,189; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No prime fails on a base it does not divide. It never will: the multiples of the base, one lot to '
          '${play.prime ? '${play.number - 1}' : 'p - 1'} lots, leave every remainder from 1 to p - 1 once each, so their product is the product of '
          'those remainders both times the base raised to p - 1 and plain, and the power is one. The sweep of all '
          '13,189 settings finds every one of the 196 primes passing on every base it does not divide, 2,142 settings.'
          '${play.prime ? ' Here ${play.number} passes on base ${play.base}, landing on ${play.landing}.' : ''}';
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
              done ? 'Tested.' : 'Every prime passes, always.',
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

/// What the number is made of, in words: 'a prime', or 'composite, 11
/// times 31'.
String madeOf(Play play) {
  if (play.prime) return 'a prime';
  final f = play.factor!;
  return 'composite, $f times ${play.number ~/ f}';
}
