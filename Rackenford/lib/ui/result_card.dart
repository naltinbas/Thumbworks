import 'package:flutter/material.dart';

import '../rack/play.dart';
import 'palette.dart';

/// The card that ends a pantry, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onPantry,
  });

  final Play play;

  /// The standing record, after this racking counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onPantry;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Every jar racked and no jar above its divisor; '
            '${play.moves} lift${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twenty-four lifts taken, and the dozen never racked '
            'clean. It never will: one, two, four and eight are '
            'a chain of four, a chain never shares a rack, and '
            'the pantry offers three.';
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
              done ? 'Racked home.' : 'The chain wants four.',
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
                  onPressed: onPantry,
                  child: const Text('The pantry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
