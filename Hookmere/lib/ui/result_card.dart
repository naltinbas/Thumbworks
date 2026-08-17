import 'package:flutter/material.dart';

import '../shape/play.dart';
import '../shape/rules.dart';
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

  /// The standing record, after this staircase counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      words = 'The staircase ${Rules.tellShape(play.rows)} has hooks '
          '${play.hooks.join(', ')}, which multiply to ${play.hookProduct}, '
          'and ${Rules.factorial(Rules.boxes)} over that is ${play.byHooks}. '
          'Counting the fillings one at a time gives ${play.counted} as well; '
          'one of ${play.level.ways} '
          '${play.level.ways == 1 ? 'staircase' : 'staircases'} of the 22 '
          'that ${play.level.ways == 1 ? 'lands' : 'land'} it; '
          '${play.moves} move${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No staircase gets the hooks wrong. Every one of the 22 was '
          'counted twice before the sham was built, once by multiplying the '
          'hooks and dividing ${Rules.factorial(Rules.boxes)} by them, and '
          'once by taking the largest number off a corner and counting the '
          'fillings of what is left, and the two agree every time. They agree '
          'for nine boxes and ten as well. This staircase, '
          '${Rules.tellShape(play.rows)}, has hooks ${play.hooks.join(', ')} '
          'multiplying to ${play.hookProduct}, and both ways of counting give '
          '${play.byHooks}.';
    }
    return Card(
      color: Palette.board,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: done ? Palette.good : Palette.bad, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              done ? 'Laid.' : 'The hooks are never wrong.',
              style: TextStyle(
                color: done ? Palette.good : Palette.bad,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(words,
                style: const TextStyle(color: Palette.ink, fontSize: 14)),
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
