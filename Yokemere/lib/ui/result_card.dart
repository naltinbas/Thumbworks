import 'package:flutter/material.dart';

import '../yoke/play.dart';
import '../yoke/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onYard,
  });

  final Play play;

  /// The standing record, after this team counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onYard;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final pairs = [
        for (var i = 0; i < Rules.oxen; i++)
          '${Rules.near[i]} with ${play.oxAt(i)}'
      ];
      words = 'Yoked ${pairs.join(', ')}, pulling ${play.pull}. One of '
          '${level.ways} ${level.ways == 1 ? 'yoking' : 'yokings'} of the '
          '120 that ${level.ways == 1 ? 'does' : 'do'} it. '
          '${play.anyCrossed ? 'Some pairs are still crossed, so this team could pull harder.' : 'Nothing is crossed here, so no swap could make it pull harder: this is the best team there is.'} '
          '${play.swaps} swap${play.swaps == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The hardest any team here can pull is ${Rules.hardest()}, and '
          '${level.pull} is past it. Take any team where a stronger near ox '
          'is yoked to a weaker off one than its neighbour and swap the two: '
          'the pull changes by the near gap multiplied by the off gap, which '
          'is never a loss. So working the crossings out one at a time walks '
          'up to the team with nothing crossed, which is the one with both '
          'rows in matching order, and there is nowhere further to walk. '
          'None of the 120 yokings does it, and the same held on 15,876 '
          'other pairs of rows.';
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
              done ? 'Yoked.' : 'Nothing pulls harder.',
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
                  onPressed: onYard,
                  child: const Text('The yard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
