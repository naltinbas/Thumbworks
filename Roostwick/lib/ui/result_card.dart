import 'package:flutter/material.dart';

import '../roost/play.dart';
import '../roost/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onWood,
  });

  final Play play;

  /// The standing record, after this settling counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onWood;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final seated =
        play.at.map((h) => Rules.letter(h)).join();
    final String words;
    if (done) {
      words = 'Birds 1 to ${play.birds.length} in hollows $seated. One of '
          '${level.ways} ${level.ways == 1 ? 'seating' : 'seatings'} of the '
          '${level.seatings} this wood has that ${level.ways == 1 ? 'settles' : 'settle'} '
          'it, counted by walking all ${level.seatings} and counted again '
          'off the patches without walking any. ${play.taps} '
          'tap${play.taps == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final holes = play.overfull;
      final jam = holes.map(Rules.letter).join(' and ');
      final penned = play.penned.length;
      words = 'Hollows $jam are the whole of it. $penned birds have both of '
          'their hollows in there and only ${holes.length} to sit in, so one '
          'of them is crowded out however they are arranged. Tapping sends a '
          'bird along its own tether and never makes a hollow, so no amount '
          'of it helps. None of the ${level.seatings} seatings settles this '
          'wood, and there are ${play.birds.length} birds and '
          '${Rules.hollows} hollows, so nothing here is short of room.';
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
              done ? 'Settled.' : 'The patch is overfull.',
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
                  onPressed: onWood,
                  child: const Text('The wood'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
