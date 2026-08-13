import 'package:flutter/material.dart';

import '../deal/play.dart';
import 'palette.dart';

/// The card that ends a handful, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onStone,
  });

  final Play play;

  /// The standing record, after this piling counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onStone;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'The hand of ${play.piles.join(', ')} stands '
            '${play.deals} deal${play.deals == 1 ? '' : 's'} from '
            'the stair; ${play.moves} '
            'move${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Nineteen movings taken, and no hand of eight ever '
            'stood still. None will: a standstill is forced '
            'into the stair, and stairs hold one, three, six '
            'or ten stones, never eight.';
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
              done ? 'Dealt home.' : 'Eight never stands.',
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
                  onPressed: onStone,
                  child: const Text('The stone'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
