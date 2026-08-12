import 'package:flutter/material.dart';

import '../post/play.dart';
import 'palette.dart';

/// The card that ends a round, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onWick,
  });

  final Play play;

  /// The standing record, after this round counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onWick;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'All ${play.round.letters} posted, '
            '${play.homes.length} home; ${play.moves} '
            'posting${play.moves == 1 ? '' : 's'} all told.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve postings and the count never came to three. '
            'It never will: three letters home of four leaves '
            'the fourth only its own hole, and the sweep of all '
            '24 rounds found the exactly-three count empty.';
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
              done ? 'Posted.' : 'The third stays out of reach.',
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
                  onPressed: onWick,
                  child: const Text('The wick'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
