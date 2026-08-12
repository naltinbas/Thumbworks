import 'package:flutter/material.dart';

import '../shake/play.dart';
import 'palette.dart';

/// The card that ends a lawn, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onFete,
  });

  final Play play;

  /// The standing record, after this lawn counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onFete;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? '${play.shakes.length} shake${play.shakes.length == 1 ? '' : 's'} '
            'on the lawn, ${play.oddHanded.length} odd-handed; '
            '${play.moves} greeting${play.moves == 1 ? '' : 's'} '
            'all told.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve greetings and never exactly one hand up. There '
            'never will be: every shake hands out two, the hand '
            'total stays even, and one odd-handed guest alone '
            'would make it odd.';
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
              done ? 'Greeted.' : 'The lone hand never rises.',
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
                  onPressed: onFete,
                  child: const Text('The fete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
