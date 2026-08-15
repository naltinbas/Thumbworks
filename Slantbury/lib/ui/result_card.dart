import 'package:flutter/material.dart';

import '../pieces/play.dart';
import 'palette.dart';

/// The card that ends a frame, either way.
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

  /// The standing record, after this laying counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Every piece lies inside the frame, ${play.overlap.sign == 0 ? 'none overlapping' : 'sharing ${play.overlap} square'} '
            'and ${play.gap.sign == 0 ? 'no square bare' : '${play.gap} square bare'}; ${play.moves} '
            'laying${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : play.sliverShown
            ? 'The four pieces lie inside with no overlap, and one square stays '
                'bare, a sliver along the slant: sixty-four squares of pieces in a '
                'frame of sixty-five, as the areas said, and Cassini\'s identity '
                'says so for every frame of the kind.'
            : 'Twenty-four layings, and the frame never filled. It never will: '
                'sixty-four squares of pieces in a frame of sixty-five leave one '
                'bare however they lie.';
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
              done ? 'Landed.' : 'The sliver stays.',
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
