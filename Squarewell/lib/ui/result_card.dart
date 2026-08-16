import 'package:flutter/material.dart';

import '../square/play.dart';
import '../square/rules.dart';
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
    final String words;
    if (done) {
      final b = play.base, p = play.clock;
      final over = (b * b - play.square) ~/ p;
      words = 'Base $b on the ${Rules.name(p)}-hour clock: $b times $b is ${b * b}, ${over == 0 ? 'less than ${Rules.name(p)}' : '$over ${Rules.name(p)}${over == 1 ? '' : 's'} and ${play.square} over'}, '
          'so it squares to ${play.square}, as does ${p - b}; the squares on ${Rules.name(p)} are ${Rules.told(play.squares)}; '
          'one of ${play.level.ways} ${play.level.locked ? 'base' : 'setting'}${play.level.ways == 1 ? '' : 's'} of ${play.level.locked ? 'its' : 'the'} ${play.level.settings}; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Two is no square on the eleven-hour clock. It never will be: the squares of 1 to 5 are 1, 4, 9, 5 '
          'and 3, and 6 to 10 repeat them backwards, so 2, 6, 7, 8 and 10 are nobody\'s square; Euler\'s test '
          'agrees, 2 to the fifth being 32, one short of three elevens.';
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
              done ? 'Squared.' : 'Two is no square.',
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
