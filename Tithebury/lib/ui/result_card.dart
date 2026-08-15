import 'package:flutter/material.dart';

import '../tithe/play.dart';
import '../tithe/rules.dart';
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
      final n = play.number, t = play.tithe;
      final divisors = play.divisors;
      final told = divisors.length <= 11 ? Rules.told(divisors) : '${divisors.length} of them, ${divisors.first} to ${divisors.last}';
      words = 'The proper divisors of $n, $told, add up to $t, '
          '${t == n ? 'the number itself' : t == 2 * n ? 'twice the number' : t > n ? '${t - n} over' : '${n - t} short'}'
          '${play.level.kind == 'friends' ? ', and the divisors of $t add up to $n' : ''}; ${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No power of two adds up to itself. It never will: its proper divisors are the '
          'powers of two below it, and 1 + 2 + 4 + ... up to half of it is one less than it, '
          'every time; 256 gets 255, and the sweep of all 500 numbers finds the nine that come '
          'one short to be exactly the powers of two.';
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
              done ? 'Tallied.' : 'One short, always.',
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
