import 'package:flutter/material.dart';

import '../chain/play.dart';
import 'palette.dart';

/// The card that ends a field, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onHurst,
  });

  final Play play;

  /// The standing record, after this landing counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onHurst;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? '${play.field.stones} stones, ${play.field.asked} bare '
            'chain${play.field.asked == 1 ? '' : 's'}, '
            '${play.moves} touch${play.moves == 1 ? '' : 'es'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Sixteen touches and every setting has shown a bare '
            'chain. Every one always will: the sweep laid all '
            '53,130 placings of five, and the only bare-less ones '
            'are the twelve rows the asking bars.';
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
              done ? 'Landed.' : 'No bare-less field.',
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
                  onPressed: onHurst,
                  child: const Text('The hurst'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
