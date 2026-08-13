import 'package:flutter/material.dart';

import '../window/play.dart';
import 'palette.dart';

/// The card that ends a house, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onWorth,
  });

  final Play play;

  /// The standing record, after this dialling counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onWorth;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'The windows ${play.windows.join(', ')} go dark in '
            'exactly ${play.turns} turn${play.turns == 1 ? '' : 's'}; '
            '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Fourteen taps taken, and three turns never showed. '
            'They never will: three windows rest only from all '
            'alike, in a single turn, and everything else '
            'circles the parity ring for ever.';
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
              done ? 'Gone dark.' : 'The ring never lands.',
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
                  onPressed: onWorth,
                  child: const Text('The worth'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
