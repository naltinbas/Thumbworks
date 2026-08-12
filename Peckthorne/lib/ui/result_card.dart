import 'package:flutter/material.dart';

import '../peck/play.dart';
import 'palette.dart';

/// The card that ends a flock, either way.
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

  /// The standing record, after this pecking counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onYard;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final crowns = play.kings.length;
    final words = done
        ? '${crowns == play.flock.chickens ? 'Every chicken crowned' : 'Exactly $crowns crowned'}, '
            'both counts agreeing; ${play.moves} '
            'flip${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve flips taken, and the pair never came. It never '
            'will: whoever pecks a king hides a further king among '
            'themselves, so crowns never stop at two; all '
            'sixty-four peckings settle at one crown or three.';
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
              done ? 'Crowned.' : 'Crowns never pair.',
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
                  child: const Text('The yard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
