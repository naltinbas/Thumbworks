import 'package:flutter/material.dart';

import '../sliver/frac.dart';
import '../sliver/play.dart';
import '../sliver/rules.dart';
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

  /// The standing record, after this setting counted.
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
      words = 'Marks ${Rules.tellMarks(play.marks)}: the ratios ${ratioWords(play)}, ${play.gone ? 'multiplying to one, so the three cuts meet at one point and the sliver comes to nothing' : 'multiplying to ${play.ratioProduct}, and the sliver takes ${Rules.tellShare(play.share)} of the field'}, '
          'by the corners and by Routh\'s rule; '
          'one of ${level.ways} setting${level.ways == 1 ? '' : 's'} of the 1,331; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No setting empties the sliver while the cuts miss one another. It never will: if the sliver has no area '
          'its three corners are one point, and that point sits on all three cuts, so the cuts meet; Routh\'s rule says '
          'the same in arithmetic, the share being the square of xyz less one over a product that never vanishes. The '
          'sweep of all 1,331 settings finds the sliver gone on 31 and the cuts meeting on the same 31.'
          '${play.gone ? ' Here the marks ${Rules.tellMarks(play.marks)} make the ratios multiply to one, and the three cuts meet at ${Rules.tellSpot(play.sliver!.first)}.' : ''}';
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
              done ? 'Cut.' : 'Together or not at all.',
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

/// The three ratios in words: '2, 2 and 2'.
String ratioWords(Play play) {
  final r = play.ratios;
  return '${r[0]}, ${r[1]} and ${r[2]}';
}

/// A share told with its whole part, for the chips.
String shareChip(Frac share) => share == Frac.zero ? 'no sliver' : 'sliver $share';
