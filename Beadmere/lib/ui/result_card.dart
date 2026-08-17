import 'package:flutter/material.dart';

import '../strip/play.dart';
import '../strip/rules.dart';
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

  /// The standing record, after this strip counted.
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
      words = '${Rules.tellStrip(play.beads)} repeats every ${level.first} '
          'and every ${level.second} and not every ${level.forced}. It is one '
          'of ${level.ways} strip${level.ways == 1 ? '' : 's'} of the '
          '${Rules.tellCount(level.strips)} that land the ask, in ${play.moves} '
          'tap${play.moves == 1 ? '' : 's'} against the ${level.fewest} the '
          'cheapest takes. At ${level.bound} beads it could not be done: '
          '${level.first} and ${level.second} would force ${level.forced}.';
    } else {
      words = 'No strip of ${level.beads} beads repeats every ${level.first} '
          'and every ${level.second} without repeating every ${level.forced}. '
          '${level.beads} is the length Fine and Wilf give, '
          '${level.first} plus ${level.second} less ${level.forced}, and at '
          'that length the two repeats force the third. One bead shorter it '
          'can be dodged, and the strips that dodge it are the Fibonacci '
          'ones. You have found ${play.seen.length} '
          'strip${play.seen.length == 1 ? '' : 's'} with both repeats, and '
          'every one of them repeats every ${level.forced} as well. None of '
          'the ${Rules.tellCount(level.strips)} strips of this length does '
          'otherwise.';
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
              done ? 'Strung.' : 'One bead too many.',
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

/// Which of the two repeats the strip has, for a chip.
String repeatChip(Play play) {
  final level = play.level;
  final has = <String>[
    if (play.hasFirst) '${level.first}',
    if (play.hasSecond) '${level.second}',
  ];
  if (has.isEmpty) return 'neither repeat yet';
  return 'repeats every ${has.join(' and every ')}';
}
