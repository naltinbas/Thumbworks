import 'package:flutter/material.dart';

import '../line/play.dart';
import '../line/rules.dart';
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

  /// The standing record, after this triangle counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      words = 'A ${Rules.tellPeg(play.a)}, B ${Rules.tellPeg(play.b)}, C ${Rules.tellPeg(play.c)}: '
          'G ${Rules.told(play.centroid)}, O ${Rules.told(play.circumcentre)}, H ${Rules.told(play.orthocentre)}; '
          'one of ${_commas(play.level.ways)} triangle${play.level.ways == 1 ? '' : 's'} of the 17,600; '
          '${play.moves} move${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The three centres never meet on the field. They never will: one point for all three '
          'makes every median a perpendicular bisector, so each side equals its neighbours and the '
          'triangle is equilateral, and no triangle on pegs is equilateral, since the tangent of an '
          'angle between two peg lines is a fraction and the tangent of sixty degrees is the square '
          'root of three, no fraction; the sweep of all 17,600 triangles finds none, and the nearest, '
          'sides squared 17, 17 and 18, still holds three centres apart.';
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
              done ? 'In a line.' : 'No equilateral on pegs.',
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
