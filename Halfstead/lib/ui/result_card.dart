import 'package:flutter/material.dart';

import '../step/play.dart';
import '../step/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
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

  /// The standing record, after this run counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final lengths = play.lengths;
      final told = lengths.length <= 7 ? lengths.map(Rules.tell).join(', ') : '${lengths.take(3).map(Rules.tell).join(', ')} and on down to ${Rules.tell(lengths.last)}';
      words = '${play.steps} step${play.steps == 1 ? '' : 's'} of ${Rules.tellShare(play.share)}, $told, add to ${Rules.tell(play.covered)}, and 1 less ${Rules.tell(play.left)} agrees; '
          'one of ${play.level.ways} setting${play.level.ways == 1 ? '' : 's'} of the ${Rules.settings}; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The wall is never reached. It never will be: each step covers a share of what is left, and the '
          'rest of something is something; after ${play.steps} steps of ${Rules.tellShare(play.share)} ${Rules.tell(play.left)} is left, and after any number a fraction '
          'above nothing, though the steps add up to as near the whole as you please. The sweep of all 200 '
          'settings finds none at the wall.';
    }
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
              done ? 'Stopped there.' : 'Never the wall.',
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
