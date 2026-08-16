import 'package:flutter/material.dart';

import '../sight/play.dart';
import '../sight/rules.dart';
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

  /// The standing record, after this tree counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final t = play.picked!;
      final g = Rules.gcd(t.$1, t.$2);
      words = 'Tree ${Rules.tell(t)}: ${play.seen ? 'in sight, ${t.$1} and ${t.$2} sharing no factor, by the factor and by the line, hiding ${Rules.tellAll(play.hides)}' : 'hidden, ${t.$1} and ${t.$2} sharing the factor $g, behind ${Rules.tellAll(play.between)}, by the factor and by the line'}; '
          'one of ${level.ways} tree${level.ways == 1 ? '' : 's'} of the 100; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final t = play.picked;
      words = 'No tree of the first row or the first file is hidden. It never will be: a tree in the first row stands one '
          'step up, and a tree on the line to it would stand less than one step up, which no tree does, and the same '
          'across for the first file; one and any number share no factor but one. The sweep of all a hundred trees finds '
          'the nineteen on the two edges in sight, every one, and a tree hidden exactly when its file and row share a factor.'
          '${t == null || !play.onEdge ? '' : ' Here ${Rules.tell(t)} is in sight, hiding ${Rules.tellAll(play.hides)}.'}';
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
              done ? 'Picked.' : 'In sight, every time.',
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
