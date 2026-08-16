import 'package:flutter/material.dart';

import '../nine/play.dart';
import '../nine/rules.dart';
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

  /// The standing record, after this number counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final (nines, over) = Rules.cast(play.number);
      words = '${play.number}: ${Rules.told(play.number)}; $nines nine${nines == 1 ? '' : 's'} and $over over; '
          'one of ${play.level.ways} number${play.level.ways == 1 ? '' : 's'} of the 1,000; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final n = play.number;
      final near = Rules.isSquare(n) && (play.root == 4 || play.root == 7)
          ? ' $n, ${_sqrt(n)} squared, roots ${play.root}, as near as a square comes to five.'
          : '';
      words = 'No square roots five. It never will: a square\'s root is the root of its root squared, '
          'and 1 to 9 squared root 1, 4, 9, 7, 7, 9, 4, 1 and 9; the sweep of the 32 squares to 961 '
          'finds roots 0, 1, 4, 7 and 9 alone.$near';
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
              done ? 'Cast.' : 'No square roots five.',
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

int _sqrt(int n) {
  var k = 0;
  while (k * k < n) {
    k++;
  }
  return k;
}
