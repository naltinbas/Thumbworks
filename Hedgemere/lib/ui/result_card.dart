import 'package:flutter/material.dart';

import '../hedge/play.dart';
import '../hedge/rules.dart';
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

  /// The standing record, after this peeling counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final middle = play.middle;
    final String words;
    if (done) {
      words = 'The hedge ${Rules.tellHanging(play.hanging)} peels to '
          '${Rules.tellMiddle(middle)} in ${Rules.tellRounds(play.rounds)}, '
          'and walking outward from every post names the same '
          '${middle.length == 1 ? 'post' : 'posts'}; one of '
          '${play.level.ways} hangings of the 720 that land it; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No hedge has three middle posts. Walk this one from one end '
          'of its longest path to the other, ${play.longest} steps, and the '
          'middle sits at the halfway mark of that walk: every round of '
          'stripping takes a step off each end, so what survives is what '
          'lies halfway along. A walk of an even number of steps has one '
          'post halfway and a walk of an odd number has two, and a line has '
          'no third place to stand halfway. Here it is '
          '${Rules.tellMiddle(middle)}. All 720 hangings the dials reach '
          'were peeled before the sham was built and every one of them left '
          'one post or two.';
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
              done ? 'Peeled.' : 'One or two, never three.',
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
