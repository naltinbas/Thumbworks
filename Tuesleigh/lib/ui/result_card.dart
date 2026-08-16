import 'package:flutter/material.dart';

import '../family/play.dart';
import '../family/rules.dart';
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

  /// The standing record, after this tally counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final k = play.tags;
      words = '$k tag${k == 1 ? ', no tag at all' : 's'}: ${play.families} families alike, ${play.told} of them with a boy of the first tag and ${play.bothBoys} of those two boys, chance ${Rules.tell(play.chance)}, '
          'a half less 1/${2 * play.told}; told which child, 1/2; '
          'one of ${play.level.ways} tag count${play.level.ways == 1 ? '' : 's'} of the ${Rules.settings}; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'A half never comes. It never will: with k tags the families holding a boy of the first tag '
          'number 4k - 1 and those of two boys among them 2k - 1, and twice 2k - 1 is 4k - 2, one short; '
          'the chance is a half less one part in twice 4k - 1, 1/6 short at one tag, 1/54 at seven and '
          '1/${2 * play.told} here at ${play.tags}, and the sweep of all 30 finds none at a half. Told which '
          'child is the tagged boy, the chance is exactly a half at every tag count.';
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
              done ? 'Counted.' : 'One family short.',
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
