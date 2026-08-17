import 'package:flutter/material.dart';

import '../rod/play.dart';
import '../rod/rules.dart';
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

  /// The standing record, after this cutting counted.
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
      final cuttings = Rules.tellProduct(BigInt.from(level.cuttings));
      words = 'The rod of ${play.hands} cut ${Rules.tellParts(play.parts)}, '
          'which multiplies to ${Rules.tellProduct(play.product)}. '
          '${level.ways == 1 ? 'The only cutting of the $cuttings that lands the ask' : 'One of ${level.ways} cuttings of the $cuttings that land the ask'}, '
          'in ${play.moves} tap${play.moves == 1 ? '' : 's'} against the '
          '${level.fewest} the fewest takes.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Nothing passes ${Rules.tellProduct(play.best)} on a rod of '
          '${play.hands}, and the reason is three lines of arithmetic. A '
          'part of five or more is better cut into a three and the rest, '
          'since three times what is left beats the part itself from five '
          'up. A one is wasted, since it multiplies nothing. And three twos '
          'should be two threes, since nine beats eight. That leaves threes '
          'with a four or a two over, and for ${play.hands} it is '
          '${Rules.tellParts(Rules.bestParts(play.hands))}. '
          'You have found the best ${play.seen.length} '
          'way${play.seen.length == 1 ? '' : 's'}, and the sweep of all '
          '${level.cuttings} cuttings finds nothing above it.';
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
              done ? 'Cut.' : 'The threes have it.',
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

/// What the cutting comes to, for a chip.
String productChip(Play play) => Rules.tellProduct(play.product);
