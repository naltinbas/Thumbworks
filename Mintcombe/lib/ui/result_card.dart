import 'package:flutter/material.dart';

import '../coin/play.dart';
import '../coin/rules.dart';
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

  /// The standing record, after this picking counted.
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
      final String how, ways;
      switch (level.kind) {
        case 'tidy':
          how = 'no two neighbours, the greedy purse\'s own picking';
          ways = level.all == 1 ? 'the one picking of the purse that pays ${level.price}' : 'the one tidy picking of the ${level.all} that pay ${level.price}';
        case 'untidy':
          how = '${_pairs(play)} neighbours';
          ways = 'one of ${level.ways} untidy pickings of the ${level.all} that pay ${level.price}';
        default:
          how = '${_pairs(play)} neighbours';
          ways = 'one of ${level.ways} pickings that pay ${level.price}, none of them tidy';
      }
      words = '${tellCoins(play.picked)}: ${level.price} paid, $how; $ways; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No tidy purse pays 90 with the 89 kept back. It never will: every other coin from a coin down '
          'adds to one short of the coin above it, and 55, 21, 8, 3 and 1 come to 88; the sweep of all 1,024 '
          'pickings finds 89 tidy ones without the 89, paying nought to 88 once each, and 90 paid tidily by '
          '89 and 1 alone.'
          '${play.stuck ? ' Here ${tellCoins(play.picked)} come to ${play.sum} and nothing more fits.' : ''}';
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
              done ? 'Paid.' : 'One short, always.',
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

/// The neighbouring pairs in words: '55 and 34', or '55 and 34, 3 and 2'.
String _pairs(Play play) => play.pairs.map((p) => '${p.$1} and ${p.$2}').join(', ');
