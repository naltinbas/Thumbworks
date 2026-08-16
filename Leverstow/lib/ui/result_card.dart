import 'package:flutter/material.dart';

import '../lever/frac.dart';
import '../lever/play.dart';
import '../lever/rules.dart';
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

  /// The standing record, after this loop counted.
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
      words = 'The loop ${Rules.tellLoop(play.loop)} climbs ${play.climb} of a '
          'coin a round, and after ${Play.rounds} rounds the purse stands at '
          '${play.purse.last.toDouble.toStringAsFixed(3)}. One of '
          '${level.ways} loop${level.ways == 1 ? '' : 's'} of the 8,190 that '
          'land the ask, in ${play.moves} tap${play.moves == 1 ? '' : 's'}, '
          'and the fewest is ${level.fewest}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final rest = Rules.resting('B');
      words = 'One lever on its own never climbs. A is a coin toss, half a '
          'coin either way, and it rests on the three remainders alike. B '
          'rests on them in the shares ${rest.join(', ')}, so five times in '
          'thirteen it stands where three divides the purse and loses four '
          'fifths of a coin, and eight times in thirteen it gains half a '
          'coin: five times four fifths is four, and eight times a half is '
          'four. The sweep of all 8,190 loops finds 8,154 that climb and 36 '
          'that stand still, and every one of the still ones is a single '
          'lever or an alternation.';
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
              done ? 'Climbing.' : 'One lever goes nowhere.',
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

/// The climb, for a chip.
String climbChip(Play play) {
  final climb = play.climb;
  if (climb == Frac.zero) return 'stands still';
  return 'climbs $climb';
}
