import 'package:flutter/material.dart';

import '../glint/level.dart';
import '../glint/play.dart';
import '../glint/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onMirror,
  });

  final Play play;

  /// The standing record, after this bounce counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onMirror;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final whole = play.paces;
      words = 'Bounced off peg ${play.bounce}, one of ${level.ways} '
          '${level.ways == 1 ? 'peg' : 'pegs'} of the ${Rules.mirror} that '
          '${level.ways == 1 ? 'brings' : 'bring'} the path within '
          '${level.paces} paces. '
          '${whole == null ? 'The two legs are no whole number of paces, and the board never works one out: it squares twice and compares whole numbers.' : 'The path is $whole paces.'}'
          '${play.even ? ' The angles match here, so this is the shortest path there is, ${Level.least} paces, the straight run to the folded eye.' : ''} '
          '${play.slides} slide${play.slides == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Fold the board along the mirror. The eye drops to its own '
          'reflection, 8 down and 6 across from the lamp, and every bounce '
          'turns into a bent path from the lamp to it. The straight run '
          'between them is ${Level.least} paces, and no bent path is '
          'shorter than a straight one. So ${Level.least} is the floor and '
          '${level.paces} is under it. None of the ${Rules.mirror} pegs '
          'does it, and none ever could: the sweep walks 54,925 settings of '
          'lamp, eye and bounce and no path anywhere comes to less than its '
          'own straight run.';
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
              done ? 'Caught.' : 'Nothing beats the straight run.',
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
                  onPressed: onMirror,
                  child: const Text('The mirror'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
