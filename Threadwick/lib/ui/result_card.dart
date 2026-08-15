import 'package:flutter/material.dart';

import '../star/play.dart';
import '../star/rules.dart';
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

  /// The standing record, after this thread counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final strokes = play.strokes;
      final each = strokes[0].length;
      words = '${Rules.count(play.nails)[0].toUpperCase()}${Rules.count(play.nails).substring(1)} nails, skip ${Rules.count(play.skip)}: '
          '${strokes.length == 1 ? 'one stroke touches all ${Rules.count(play.nails)}' : 'the thread comes home after ${Rules.count(each)} nails, and ${Rules.count(strokes.length)} strokes of ${Rules.count(each)} cover the ring'}, '
          'since ${Rules.count(play.nails)} and ${Rules.count(play.skip)} share ${strokes.length == 1 ? 'no factor' : 'the factor ${Rules.count(strokes.length)}'}; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No skip threads the six-pointed star in one stroke. It never will: six is two '
          'threes, skips two and four share the two and come home after three nails, skip '
          'three shares the three and bounces between two, and skips one and five only run '
          'round the rim; the star is two triangles, two strokes, and the walk of all five '
          'skips finds no other.';
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
              done ? 'Threaded.' : 'Two strokes, never one.',
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
