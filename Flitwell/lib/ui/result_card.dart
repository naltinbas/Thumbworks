import 'package:flutter/material.dart';

import '../flit/play.dart';
import '../flit/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onLane,
  });

  final Play play;

  /// The standing record, after this lane counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onLane;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final firsts = play.topped.length;
      words = 'Tenants A to D in cottages ${Rules.write(play.where)}. One of '
          '${level.ways} ${level.ways == 1 ? 'lane' : 'lanes'} of the 24 that '
          '${level.ways == 1 ? 'lands' : 'land'} it, found by trying all 24 '
          'against every group of tenants. $firsts of the four '
          '${firsts == 1 ? 'has' : 'have'} the cottage they want most. '
          '${play.swaps} swap${play.swaps == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final firm = level.firmLane;
      final tops = Rules.topped(level.orders, firm);
      final named = tops.map(Rules.letter).join(', ');
      words = 'In the firm lane, ${Rules.write(firm)}, tenants $named are '
          'each in the cottage they want most out of all four. No lane '
          'anywhere can leave any of them better off, so no lane can leave '
          'all four better off. The trading rings say it without trying a '
          'lane: whoever is in the first ring takes their first choice, so '
          'nothing ever beats the lane the rings give. None of the 24 lanes '
          'here does.';
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
              done ? 'Flitted.' : 'Nothing beats the firm lane.',
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
                  onPressed: onLane,
                  child: const Text('The lane'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
