import 'package:flutter/material.dart';

import '../kith/frac.dart';
import '../kith/play.dart';
import '../kith/rules.dart';
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

  /// The standing record, after this plan counted.
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
      words = '${Rules.tell(play.plan)}: ${countWords(play)}; people average ${tellFrac(play.average)} friends, '
          'the friends named ${tellFrac(play.friendsAverage!)}, by the naming and by the squares, a gap of ${tellFrac(play.gap!)}; '
          'one of ${_commas(level.ways)} plan${level.ways == 1 ? '' : 's'} of the 32,767; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final f = play.friendsAverage;
      words = 'No plan puts the friends named behind. It never will: a person with k friends is named k times, so '
          'the friends\' average is the sum of the squares of the counts over the sum of the counts, which is the '
          'plain average plus the spread of the counts over it, and a spread is never below nought; the sweep of all '
          '32,767 plans finds the two averages level on the 171 where everyone has the same number of friends and '
          'the friends named ahead on every other.'
          '${f == null ? '' : ' Here people average ${tellFrac(play.average)} and the friends named ${tellFrac(f)}${play.gap == Frac.zero ? ', level, as low as it goes' : ''}.'}';
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
              done ? 'Befriended.' : 'Never behind, always.',
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

/// Everyone's count in words: 'everyone 1', or 'Ann 5, Bess 1, Cal 1,
/// Dot 1, Ed 1, Fay 1'.
String countWords(Play play) {
  final d = play.degrees;
  if (d.every((x) => x == d.first)) return 'everyone ${d.first}';
  return [for (var v = 0; v < Rules.people; v++) '${Rules.names[v]} ${d[v]}'].join(', ');
}

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
