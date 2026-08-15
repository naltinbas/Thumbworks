import 'package:flutter/material.dart';

import '../duel/play.dart';
import '../duel/rules.dart';
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

  /// The standing record, after this duel counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      words = 'Ash ${Rules.count(play.ash)} coin${play.ash == 1 ? '' : 's'} to Birch\'s ${Rules.count(play.birch)}, the coin '
          '${Rules.coinNames[play.coin]}: Ash takes the pot ${Rules.chanceTold(play.chance)}, ${play.chance}, and the duel lasts '
          '${play.lasts} toss${play.lasts == Frac.one ? '' : 'es'} on average; ${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No purses make the duel even against the coin. They never will: with the coin '
          'against him Ash\'s chance is 2 to his purse less 1 over 2 to the pot less 1, and a '
          'half would need the number under to be twice the number over, but 2 to the pot less '
          '1 is odd, and an odd number is never twice anything; the nearest of the 108 settings '
          'is six coins to one, 63/127.';
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
              done ? 'Staked.' : 'Never even.',
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
