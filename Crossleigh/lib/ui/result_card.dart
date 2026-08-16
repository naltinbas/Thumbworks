import 'package:flutter/material.dart';

import '../cut/play.dart';
import '../cut/rules.dart';
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

  /// The standing record, after this line counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final (f, d, e) = play.crossings!;
      final r = play.ratios!;
      words = 'Line through ${Rules.tellPeg(play.p!)} and ${Rules.tellPeg(play.q!)}: F ${Rules.tellPoint(f)}, D ${Rules.tellPoint(d)}, E ${Rules.tellPoint(e)}; '
          'AF:FB ${r.$1}, BD:DC ${r.$2}, CE:EA ${r.$3}, product ${Rules.product(r)}, by the crossings and by the areas; '
          '${play.sidesInside} side${play.sidesInside == 1 ? '' : 's'} cut inside; '
          'one of ${_commas(play.level.ways)} line${play.level.ways == 1 ? '' : 's'} of the 6,140; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No line cuts all three sides inside. It never will: a straight line that goes into a triangle '
          'at one side comes out at another and cannot come back for the third, so it cuts two sides '
          'inside or none; the sweep of all 6,140 lines through two pegs that cross the three side-lines '
          'finds 5,572 cutting two inside and 568 none, and not one cutting one or three.'
          '${play.crosses ? ' Here the line cuts ${play.sidesInside} inside.' : ''}';
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
              done ? 'Cut.' : 'In and out, once.',
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

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
