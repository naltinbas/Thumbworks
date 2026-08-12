import 'package:flutter/material.dart';

import '../slice/play.dart';
import 'palette.dart';

/// The card that ends a cake, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onBury,
  });

  final Play play;

  /// The standing record, after this cutting counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onBury;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Exactly ${play.slices} slices, Euler and the cut '
            'count agreeing; ${play.moves} '
            'move${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Sixteen settings and liftings taken, and thirty-two '
            'never came. It never will: one plus fifteen lines '
            'plus fifteen crossings at the very most is '
            'thirty-one, and clumped crossings only lose.';
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
              done ? 'Cut true.' : 'The doubling lied.',
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
                  onPressed: onBury,
                  child: const Text('The bury'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
