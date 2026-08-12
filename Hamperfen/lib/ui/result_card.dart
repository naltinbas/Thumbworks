import 'package:flutter/material.dart';

import '../basket/play.dart';
import 'palette.dart';

/// The card that ends a fen, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onFen,
  });

  final Play play;

  /// The standing record, after this picking counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onFen;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? '${play.fen.take} baskets taken and none swallows '
            'another; ${play.moves} '
            'taking${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Fourteen takings and a swallowing in every seventh '
            'basket. There always will be: the shelf weighing '
            'tops out at twelve twelfths, and seven baskets '
            'weigh fourteen at the least.';
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
              done ? 'Taken.' : 'The seventh never fits.',
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
                  onPressed: onFen,
                  child: const Text('The fen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
