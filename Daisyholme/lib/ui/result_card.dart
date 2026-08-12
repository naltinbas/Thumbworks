import 'package:flutter/material.dart';

import '../daisy/play.dart';
import 'palette.dart';

/// The card that ends a circle, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onHolme,
  });

  final Play play;

  /// The standing record, after this settling counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onHolme;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Every pair shares exactly one friend, the daisy '
            'standing; ${play.moves} move${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve befriendings and partings taken, and the '
            'circle never settled. It never will: friends pair '
            'off around anyone, so counts come even, and an '
            'even crowd of four leaves only the ring, where '
            'neighbours share nobody.';
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
              done ? 'Settled.' : 'The crowd must come odd.',
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
                  onPressed: onHolme,
                  child: const Text('The holme'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
