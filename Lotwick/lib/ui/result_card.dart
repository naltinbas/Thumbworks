import 'package:flutter/material.dart';

import '../ring/play.dart';
import '../ring/rules.dart';
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
    final String words;
    if (done) {
      words = 'A beast worth ${Rules.tellCrowns(play.worth)} to you, a bid of '
          '${play.bid} against a best rival bid of ${play.rival} in '
          '${Rules.tellRing(play.ring)}: '
          '${play.takesIt ? 'you take it and pay ${play.ring == Rules.sealed ? play.rival : play.bid}' : 'the rivals take it'}, '
          'so the bid earns ${Rules.tellCrowns(play.paid)} where the truthful '
          'bid earns ${Rules.tellCrowns(play.truthPaid)}; one of '
          '${play.level.ways} settings of the 2,197 that land it; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'In the sealed ring your bid never sets the price. It settles '
          'only whether you win, and then you pay what the best rival bid. '
          'Push the bid above the worth and the only beasts it takes are the '
          'ones already bid at or past their worth, bought for at least what '
          'they are worth; pull it under and the only beasts it drops are the '
          'ones you would have taken under their worth, a gain thrown away. '
          'In between nothing changes. Here the bid of ${play.bid} earns '
          '${Rules.tellCrowns(play.paid)} against a rival at ${play.rival}, '
          'and the truthful bid of ${play.worth} earns '
          '${Rules.tellCrowns(play.truthPaid)}. Every setting of the three '
          'dials was run before the sham was built, a million of them at a '
          'hundred crowns a dial, and not one bid beat the truth.';
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
              done ? 'Sold.' : 'The truth is never beaten.',
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
