import 'package:flutter/material.dart';

import '../plot/play.dart';
import '../plot/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onField,
  });

  final Play play;

  /// The standing record, after this cut counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onField;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final sizes = play.sizes..sort();
      final motley = play.motley.length;
      words = 'Plots of ${sizes.join(', ')} half acres, coming to '
          '${Rules.field}. One of ${level.ways} '
          '${level.ways == 1 ? 'cut' : 'cuts'} that '
          '${level.ways == 1 ? 'does' : 'do'} it, counted by laying plots '
          'over the ${Rules.cells} cells the pegs\' own lines make and '
          'counted again with no cells at all. $motley of the plots '
          '${motley == 1 ? 'wears' : 'wear'} all three colours, which is an '
          'odd number, as it is on every one of the 26,822,326 cuts of this '
          'field. ${play.taps} tap${play.taps == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final shown = play.asThree;
      final sizes = shown.sizes..sort();
      words = 'Every cut of this field into three plots comes out '
          '${sizes.join(', ')} half acres, all 32 of them, because a cut '
          'into three always leaves one plot standing on a whole side and a '
          'whole side is half the field, the plot ringed in blue. Half is '
          'not a third. Monsky\'s own reason says more: the plot ringed in '
          'gold wears all three peg colours, every such plot is an odd '
          'number of half acres, and 6 is not odd. He proved in 1970 that no '
          'odd number of equal triangles cuts a square at all, pegs or no '
          'pegs.';
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
              done ? 'Cut.' : 'Three equal plots are not to be had.',
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
                  onPressed: onField,
                  child: const Text('The field'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
