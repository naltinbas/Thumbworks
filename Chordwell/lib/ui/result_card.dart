import 'package:flutter/material.dart';

import '../chord/play.dart';
import '../chord/rules.dart';
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

  /// The standing record, after this crossing counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final p = play.crossing!;
      final products = play.products!;
      words = 'Chords ${Rules.tellPeg(play.peg(0))} to ${Rules.tellPeg(play.peg(1))} and ${Rules.tellPeg(play.peg(2))} to ${Rules.tellPeg(play.peg(3))}, '
          'crossing at ${Rules.tellPoint(p)}: ${Rules.tellLength(Rules.piece2(p, play.peg(0)))} times ${Rules.tellLength(Rules.piece2(p, play.peg(1)))} '
          'and ${Rules.tellLength(Rules.piece2(p, play.peg(2)))} times ${Rules.tellLength(Rules.piece2(p, play.peg(3)))}, both ${products.$1}; '
          'one of ${play.level.ways} crossing${play.level.ways == 1 ? '' : 's'} of the 495; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final p = play.crossing;
      final near = p == null ? '' : ' Here at ${Rules.tellPoint(p)} both are ${Rules.power(p)}.';
      words = 'The two products never differ. They never will: join A to C and B to D, and the triangles '
          'PAC and PDB have the same angles, the ones at A and D standing on the same arc, so PA over PD '
          'is PC over PB and PA times PB is PC times PD; on this wheel both are 25 less the crossing\'s '
          'distance from the middle squared, and the sweep of all 495 crossings finds them equal every '
          'time.$near';
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
              done ? 'Crossed.' : 'Always equal.',
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

