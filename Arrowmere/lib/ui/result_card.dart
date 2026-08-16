import 'package:flutter/material.dart';

import '../ways/play.dart';
import '../ways/rules.dart';
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

  /// The standing record, after this orientation counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final village = play.village;
    final String words;
    if (done) {
      words = 'Every one of the ${play.wanted} ways round is open, on '
          '${play.moves} turn${play.moves == 1 ? '' : 's'}, and the fewest '
          '${village.name} takes from the opening is ${level.fewest}. One of '
          '${level.ways} orientation${level.ways == 1 ? '' : 's'} of the '
          '${village.orientations} that land it.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final lane = Rules.bridges(village).single;
      final (from, to) = Rules.pointed(village, play.arrows, lane);
      words = 'No pointing of the toll lane works, and none ever will. The '
          'lane between ${Rules.tellPlace(village.streets[lane].$1)} and '
          '${Rules.tellPlace(village.streets[lane].$2)} is the only way from '
          'one hamlet to the other, so pointing it '
          '${Rules.tellPlace(from)} to ${Rules.tellPlace(to)} leaves the far '
          'hamlet reachable and never leavable. That is Robbins\' theorem '
          'from the easy side: a street whose closing cuts the village in two '
          'cannot be pointed at all. The sweep of all '
          '${village.orientations} orientations gets ${level.bestPairs} of '
          'the ${play.wanted} ways round at best, and you have '
          '${play.pairs} of them.';
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
              done ? 'All ways round.' : 'One way and no way back.',
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

/// How far round the village goes, for a chip.
String pairsChip(Play play) => '${play.pairs} of ${play.wanted} ways round';
