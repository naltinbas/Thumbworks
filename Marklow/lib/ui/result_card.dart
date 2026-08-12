import 'package:flutter/material.dart';

import '../mark/play.dart';
import 'palette.dart';

/// The card that ends a low, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onLow,
  });

  final Play play;

  /// The standing record, after this numbering counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onLow;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? '${play.low.posts} posts marked, the gaps running 1 '
            'to ${play.low.lines.length}; ${play.moves} '
            'marking${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve markings and the ring never graced. It never '
            'will: round a ring the gaps sum even, and gaps of 1 '
            'to 5 must sum to fifteen.';
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
              done ? 'Graced.' : 'The ring stays sullen.',
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
                  onPressed: onLow,
                  child: const Text('The low'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
