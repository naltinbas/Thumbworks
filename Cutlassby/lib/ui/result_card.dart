import 'package:flutter/material.dart';

import '../deck/play.dart';
import 'palette.dart';

/// The card that ends a crew, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onSham,
  });

  final Play play;

  /// The standing record, after this paying counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'The plan passed, ${play.ayes} ayes of ${play.pirates}, and the captain '
            'keeps ${play.kept} coins; ${play.moves} given.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : play.missed
            ? (play.passes
                ? 'The plan passed, but the captain keeps only ${play.kept}; the crew '
                    'would have taken less.'
                : 'The plan failed, ${play.ayes} aye${play.ayes == 1 ? '' : 's'} of '
                    '${play.pirates}, and the captain goes over the side.')
            : '${play.passes ? 'The plan passed, but the captain keeps only ${play.kept}.' : 'The plan failed, and the captain goes over the side.'} '
                'Nine never passes: with one coin to give the captain needs two more '
                'ayes, and one coin buys one aye from a pirate who expects nothing, '
                'never two.';
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
              done ? 'Landed.' : play.missed ? (play.passes ? 'Passed, but poor.' : 'Overboard.') : 'Nine never passes.',
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
                  onPressed: onSham,
                  child: const Text('The sham'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
