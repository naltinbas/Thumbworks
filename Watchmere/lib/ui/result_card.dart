import 'package:flutter/material.dart';

import '../watch/play.dart';
import 'palette.dart';

/// The card that ends a mere, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onMere,
  });

  final Play play;

  /// The standing record, after this dialling counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onMere;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Dialled home: ${play.pairs} '
            'pair${play.pairs == 1 ? '' : 's'} overlapping and '
            '${play.commonWidth} shared '
            'hour${play.commonWidth == 1 ? '' : 's'}; '
            '${play.moves} slide${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Sixteen slides taken, and the ring never went '
            'without its hour. It never will: the latest riser '
            'and the earliest turner-in overlap like any pair, '
            'and their shared hour sits inside everybody.';
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
              done ? 'Dialled home.' : 'The ring keeps its hour.',
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
                  onPressed: onMere,
                  child: const Text('The mere'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
