import 'package:flutter/material.dart';

import '../beat/play.dart';
import '../beat/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onRing,
  });

  final Play play;

  /// The standing record, after this laying counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onRing;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final up = play.aloft;
      words = 'Throws ${play.laid.join(', ')} on beats 0 to '
          '${Rules.beats - 1}, coming down on '
          '${play.landings.join(', ')}, which is the five beats in some '
          'order. One of ${level.ways} '
          '${level.ways == 1 ? 'laying' : 'layings'} of the ${level.layings} '
          'that ${level.ways == 1 ? 'juggles' : 'juggle'}. The throws come to '
          '${level.total} over ${Rules.beats} beats, so ${level.balls} balls, '
          'and counting them in the air beat by beat gives ${up.join(', ')}. '
          '${play.taps} tap${play.taps == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The five throws come to ${level.total}, and ${level.total} '
          'into ${Rules.beats} will not go. Laying them in a different order '
          'moves the same five tiles about, so the total never changes. Any '
          'pattern at all keeps a whole number of balls up and that number '
          'is the throws added over the beats, so a rack that does not go '
          'round evenly juggles no way whatever. Four throws will go down, '
          'ten different ways, and the fifth is refused from every free beat. '
          'All 74 racks of five single-figure throws adding to ${level.total} '
          'are the same story.';
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
              done ? 'Juggled.' : 'It will not go round.',
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
                  onPressed: onRing,
                  child: const Text('The ring'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
