import 'package:flutter/material.dart';

import '../plait/play.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onWalk,
  });

  final Play play;

  /// The standing record, after this painting counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onWalk;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final painted = [
        for (var arc = 0; arc < play.paint.length; arc++)
          '${Play.letter(arc)} ${Palette.names[play.paint[arc]]}',
      ];
      words = 'Painted ${painted.join(', ')}. Every one of the '
          '${level.word.length} crossings shows three colours. One of '
          '${level.ways} paintings of the ${_commas(level.allPaintings)} that '
          'do it. ${play.taps} tap${play.taps == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Suppose every crossing showed three colours. The first two '
          'crossings both take ropes A and B, so the third rope at each has '
          'to be whichever colour is left over, which makes those two ropes '
          'the same. The third crossing wants those very two ropes '
          'different, and they are not. So some crossing shows one colour, '
          'and one more crossing then carries that colour round the rest of '
          'the rope. Only 3 of the 81 paintings keep the rule and all three '
          'are one colour from end to end. The trefoil has 6 in all three '
          'colours, and no pulling about turns a count of 6 into a count of '
          '0, so this is not the trefoil.';
    }
    return Card(
      color: Palette.board,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: done ? Palette.good : Palette.bad, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              done ? 'Painted.' : 'One colour or none.',
              style: TextStyle(
                color: done ? Palette.good : Palette.bad,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(words,
                style: const TextStyle(color: Palette.ink, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: onAgain,
                  child: const Text('Again'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: onWalk,
                  child: const Text('The rope walk'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _commas(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
