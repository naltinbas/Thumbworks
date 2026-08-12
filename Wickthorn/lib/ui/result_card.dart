import 'package:flutter/material.dart';

import '../rope/play.dart';
import 'palette.dart';

/// The card that ends a green, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onGreen,
  });

  final Play play;

  /// The standing record, after this closing counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onGreen;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Every pair of ${play.green.lanterns} lanterns shares '
            'exactly one rope; ${play.moves} '
            'rope${play.moves == 1 ? '' : 's'} strung.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve ropes strung and the green never closed. It '
            'never will: each of the six '
            'lanterns must share a rope with five others, two at '
            'a time, and two and a half ropes is nobody\'s count.';
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
              done ? 'Closed.' : 'The green stays open.',
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
                  onPressed: onGreen,
                  child: const Text('The village'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
