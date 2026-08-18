import 'package:flutter/material.dart';

import '../table/play.dart';
import '../table/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onHall,
  });

  final Play play;

  /// The standing record, after this seating counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onHall;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      words = 'Seated ${play.mark}, ${play.laid} tables of '
          '${play.sizes.join(', ')}. One of ${level.ways} seatings of the '
          '203 that ${level.ways == 1 ? 'does' : 'do'} it, counted by '
          'walking every seating and counted again from the last guest '
          'alone, who either joins a table already laid or takes a trestle '
          'of their own. ${play.moves} move${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Four tables holding four different numbers, with nobody left '
          'standing, want at least one guest, then two, then three, then '
          'four. That is ${Rules.fewestFor(level.tables)} guests and there '
          'are ${Rules.guests}. So it cannot be done here, and it could not '
          'be done with seven, eight or nine either. The sweep agrees: none '
          'of the 203 seatings does it. No counting was needed to know that, '
          'only the adding up.';
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
              done ? 'Seated.' : 'There are not enough guests.',
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
                  onPressed: onHall,
                  child: const Text('The hall'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
