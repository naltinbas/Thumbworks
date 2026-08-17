import 'package:flutter/material.dart';

import '../lane/play.dart';
import '../lane/rules.dart';
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

  /// The standing record, after this standing counted.
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
      final best = level.best;
      words = 'The pump at spot ${play.spot} and the walking at ${play.walk}, '
          'which is the least there is. The houses stand at '
          '${Rules.tellHouses(play.houses)}, and the middle of them is '
          '${best.length == 1 ? 'spot ${best.first}' : 'anywhere from spot ${best.first} to ${best.last}'}: '
          '${level.ways} of the ${Rules.spots} spots '
          '${level.ways == 1 ? 'lands' : 'land'} it. The average falls at '
          'spot ${Rules.averageSpot(play.houses)}, where the walking comes to '
          '${Rules.walk(play.houses, Rules.averageSpot(play.houses))}. '
          '${play.moves} step${play.moves == 1 ? '' : 's'} against the '
          '${level.fewest} the nearest takes.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Nothing on the lane walks less than ${level.walk}. Step the '
          'pump one spot along and the total changes by the houses at or '
          'behind it less the houses ahead: at spot ${play.spot} that is '
          '${play.stepChange >= 0 ? 'a gain of ${play.stepChange}' : 'a saving of ${-play.stepChange}'}. '
          'While more houses lie ahead the total falls and once more lie '
          'behind it rises, so the least sits at the middle house, spot '
          '${level.best.first}, and it comes to ${level.walk}. You have '
          'stood on ${play.seen.length} of the best '
          'spot${play.seen.length == 1 ? '' : 's'}, and the sweep of all '
          '${Rules.spots} finds nothing under it.';
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
              done ? 'Least walking.' : 'The middle has it.',
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

/// What the walking comes to, for a chip.
String walkChip(Play play) => 'walking ${play.walk}';

/// Which way it would go, for a chip.
String stepChip(Play play) {
  final change = play.stepChange;
  if (change == 0) return 'a step along changes nothing';
  return change < 0
      ? 'a step along saves ${-change}'
      : 'a step along costs $change';
}
