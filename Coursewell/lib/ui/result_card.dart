import 'package:flutter/material.dart';

import '../course/play.dart';
import 'palette.dart';

/// The card that ends a yard, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onYard,
  });

  final Play play;

  /// The standing record, after this laying counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onYard;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final seams = play.seams.length;
    final words = done
        ? '${seams == 0 ? 'No line runs the yard wall to wall' : seams == 1 ? 'One line runs the yard unbroken' : 'Exactly $seams lines run the yard unbroken'}; ${play.moves} move${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Eighteen layings and liftings taken, and a seam still '
            'stands. One always will: every brick crosses one '
            'line, a crossed line is crossed twice at least, and '
            'ten lines want twenty crossings where eighteen '
            'bricks carry eighteen.';
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
              done ? 'Bricked.' : 'The yard always cracks.',
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
                  onPressed: onYard,
                  child: const Text('The yards'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
