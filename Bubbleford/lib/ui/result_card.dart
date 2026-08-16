import 'package:flutter/material.dart';

import '../kiss/play.dart';
import '../kiss/rules.dart';
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
    final level = play.level;
    final String words;
    if (done) {
      words = 'Bends ${Rules.tell(play.bends)}: the fourths ${play.inner} in the gap and ${play.outer} ${outerWords(play)}, by the formula and by the relation tried whole bend by whole bend, '
          'the pairwise sum ${play.pairs}${play.whole ? ', a square' : ''}; '
          'one of ${level.ways} setting${level.ways == 1 ? '' : 's'} of the 8,000; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No three bends give twin fourths. They never will: the fourth bend is the three added, give or take twice '
          'the root of ab + bc + ca, and the two are of one bend only when that root is nought, which three products of '
          'positive numbers never add to; the sweep of all 8,000 settings finds the two fourths apart on every one, and '
          'Descartes\' relation holding for every whole fourth found by trial.'
          ' Here the bends ${Rules.tell(play.bends)} give ${play.inner} and ${play.outer}, apart by ${apartWords(play)}.';
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
              done ? 'Kissed.' : 'Apart, every time.',
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

/// Where the outer bubble is, in words.
String outerWords(Play play) => play.outerSign < 0 ? 'round the outside' : play.outerSign == 0 ? 'flattened to a line' : 'in the far gap';

/// How far the two fourths stand apart, in words: '16', or '4 root 3'.
String apartWords(Play play) {
  final r = Rules.root(play.pairs);
  if (r != null) return '${4 * r}';
  var m = 1, n = play.pairs;
  for (var f = 2; f * f <= n; f++) {
    while (n % (f * f) == 0) {
      n ~/= f * f;
      m *= f;
    }
  }
  return '${4 * m} root $n';
}
