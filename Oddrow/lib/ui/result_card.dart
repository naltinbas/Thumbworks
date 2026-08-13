import 'package:flutter/material.dart';

import '../row/play.dart';
import 'palette.dart';

/// The card that ends an asking, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onWall,
  });

  final Play play;

  /// The standing record, after this winding counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onWall;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'Row ${play.at} holds exactly ${play.odds} odds, the '
            'three counts agreeing; ${play.moves} '
            'wind${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve winds taken, and three odds never showed. '
            'They never will: every lit bit doubles the count, '
            'so it runs one, two, four, eight, sixteen, and '
            'three is no power of two.';
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
              done ? 'Wound home.' : 'The doubling allows no three.',
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
                  onPressed: onWall,
                  child: const Text('The wall'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
