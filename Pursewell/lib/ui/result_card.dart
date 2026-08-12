import 'package:flutter/material.dart';

import '../purse/play.dart';
import 'palette.dart';

/// The card that ends a purse, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onWell,
  });

  final Play play;

  /// The standing record, after this payment counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onWell;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? '${play.purse.price} paid with '
            '${play.tray.length} coin${play.tray.length == 1 ? '' : 's'}, '
            'no neighbours; ${play.moves} '
            'move${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve coins in and out, and twelve only ever paid '
            'the one way. It only ever will: the sweep tried '
            'every lawful handful for every purse to a hundred '
            'and found exactly one payment each.';
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
              done ? 'Paid.' : 'The second way stays unfound.',
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
                  onPressed: onWell,
                  child: const Text('The well'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
