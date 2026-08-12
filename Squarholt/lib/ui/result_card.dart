import 'package:flutter/material.dart';

import '../hoard/play.dart';
import 'palette.dart';

/// The card that ends a hoard, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onHolt,
  });

  final Play play;

  /// The standing record, after this paying counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onHolt;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Paid exactly: ${play.a * play.a} and '
            '${play.b * play.b} make ${play.paid}; ${play.moves} '
            'turn${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Sixteen turns taken, and the hoard never paid. It '
            'never will: a square tile pays nought or one past a '
            'four-times, two together reach two past at the '
            'most, and forty-three sits three past.';
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
              done ? 'Paid.' : 'Three past never pays.',
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
                  onPressed: onHolt,
                  child: const Text('The holt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
