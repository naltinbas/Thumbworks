import 'package:flutter/material.dart';

import '../mill/play.dart';
import 'palette.dart';

/// The card that ends a grind, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onMill,
  });

  final Play play;

  /// The standing record, after this winding counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onMill;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Wound to ${play.wound}, and the factorial ends in '
            '${play.noughts} nought${play.noughts == 1 ? '' : 's'}; '
            '${play.moves} winding${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twenty-four windings and never five noughts on the '
            'end. There never will be: twenty-four grinds four, '
            'and twenty-five brings its second five along, '
            'grinding six.';
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
              done ? 'Ground.' : 'The fifth nought never falls.',
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
                  onPressed: onMill,
                  child: const Text('The mill'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
