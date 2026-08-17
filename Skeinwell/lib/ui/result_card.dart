import 'package:flutter/material.dart';

import '../skein/play.dart';
import '../skein/rules.dart';
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

  /// The standing record, after this village counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final shares = play.shares;
    final String words;
    if (done) {
      words = 'The village ${Rules.tellVillage(play.village)} strings '
          '${play.stringings} '
          '${play.stringings == 1 ? 'way' : 'ways'}, and the shares '
          '${Rules.laidLanes(play.village).map((lane) => '${shares[lane]}').join(', ')} '
          'add to ${play.total}, counted lane by lane and carried through '
          'again as traffic; one of ${play.level.ways} '
          '${play.level.ways == 1 ? 'village' : 'villages'} of the 728 that '
          '${play.level.ways == 1 ? 'lands' : 'land'} it; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The shares always add to four. Every stringing of this '
          'village uses four lanes, never more and never fewer, since four '
          'lanes are what it takes to join five greens without closing a '
          'loop. Adding the shares counts the lanes of every stringing once '
          'each, ${play.stringings} '
          '${play.stringings == 1 ? 'stringing' : 'stringings'} of four '
          'lanes apiece over ${play.stringings} of them, so the total is '
          'four and here it is ${play.total}. All 728 villages that join '
          'their greens up were strung in full before the sham was built '
          'and every one of them came to four.';
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
              done ? 'Strung.' : 'Four, whatever you lay.',
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
