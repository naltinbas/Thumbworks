import 'package:flutter/material.dart';

import '../heap/play.dart';
import '../heap/rules.dart';
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

  /// The standing record, after this heaping counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final heap = play.slots.map((s) => s!).toList()..sort();
      final n = play.level.number;
      final squares = Rules.oddSquares(n);
      final shown = squares.take(2).map((s) => s.map((r) => '$r squared').join(' + ')).join(' or ');
      words = '$n = ${Rules.told(heap)}, one of ${play.level.ways} heap${play.level.ways == 1 ? '' : 's'} of ${play.level.slots == 2 ? 'two' : 'three'}; '
          '8 times $n plus 3 is ${8 * n + 3}, which is $shown${squares.length > 2 ? ' and ${squares.length - 2} more ways' : ''}, '
          'one for each heap of three; ${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No two triangular numbers make five. They never will: below five they are 0, 1 and 3, '
          'and their pairs add to 0, 1, 2, 3, 4 and 6; three do it, 3 + 1 + 1, and the sweep to 500 '
          'finds every number three heaps and 212 of them no two.';
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
              done ? 'Heaped.' : 'Two heaps never make five.',
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
