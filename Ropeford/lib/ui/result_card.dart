import 'package:flutter/material.dart';

import '../ford/play.dart';
import '../ford/rules.dart';
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
    final level = play.level;
    final String words;
    if (done) {
      words = 'Stone ${play.at}, by ${play.stones.join(', ')}: '
          '${play.moves} hop${play.moves == 1 ? '' : 's'}, and the fewest the '
          'ford allows is ${level.fewest}. '
          'One of ${level.ways} stone${level.ways == 1 ? '' : 's'} of the '
          '${Rules.stones} that land the ask.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No crossing ends between 89 and 97. The seven stones there are '
          'all mossy: 90, 92, 94 and 96 are even, ${Rules.tellMoss(93)}, '
          '${Rules.tellMoss(95)}, and ${Rules.tellMoss(91)}. Bertrand\'s '
          'postulate promises a dry stone somewhere under the rope, never one '
          'where you want it: from stone ${play.at} the rope reaches '
          '${play.rope}, and ${play.inReach.isEmpty ? 'the ford runs out first' : 'the dry stones under it are ${play.inReach.join(', ')}'}.';
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
              done ? 'Across.' : 'Not there, not ever.',
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

/// What the stones in reach come to, for a chip.
String reachChip(Play play) {
  final reach = play.inReach;
  if (reach.isEmpty) return 'nothing dry left';
  return '${reach.length} dry in reach';
}
