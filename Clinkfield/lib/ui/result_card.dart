import 'package:flutter/material.dart';

import '../clink/play.dart';
import 'palette.dart';

/// The card that ends a feast, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onField,
  });

  final Play play;

  /// The standing record, after this feast counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onField;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'The counts run ${(List.of(play.counts)..sort((a, b) => b - a)).join(', ')}: '
            '${play.distinct} different; ${play.moves} '
            'move${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Fourteen clinks and takings-back, and the counts '
            'never all differed. They never will: five different '
            'counts need both the wallflower and the toast of '
            'the table, and those two cannot share a feast.';
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
              done ? 'Feasted.' : 'Two always clink alike.',
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
                  onPressed: onField,
                  child: const Text('The field'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
