import 'package:flutter/material.dart';

import '../debt/play.dart';
import 'palette.dart';

/// The card that ends a village, either way.
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

  /// The standing record, after this settlement counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onFen;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Every house clear in ${play.moves} '
            'move${play.moves == 1 ? '' : 's'}; the proven fewest '
            'is ${play.village.fewest}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve moves and the debt still stands. It always '
            'will: no move changes a spread\'s class, this '
            'village\'s burning leaves the bank in debt, and the '
            'search finds no settlement to any depth it can reach.';
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
              done ? 'Settled.' : 'The pound stays short.',
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
