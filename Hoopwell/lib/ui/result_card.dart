import 'package:flutter/material.dart';

import '../hoop/play.dart';
import '../hoop/rules.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onHoop,
  });

  final Play play;

  /// The standing record, after this board counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onHoop;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final most = play.ways.reduce((a, b) => a > b ? a : b);
      words = 'Dark in ${Rules.at(play.dark).join(', ')} and pale in '
          '${Rules.at(play.pale).join(', ')}, lighting '
          '${Rules.at(play.lamps).join(', ')}. One of ${level.ways} boards of '
          'the ${level.boards} with those stones that '
          '${level.ways == 1 ? 'does' : 'do'} it, counted by piling the '
          'turned copies and counted again by multiplying the rings out. The '
          'busiest lamp here is lit $most '
          '${most == 1 ? 'way' : 'ways'}, and the floor for ${level.dark} and '
          '${level.pale} stones is ${level.floor}. ${play.taps} '
          'tap${play.taps == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The floor for ${level.dark} dark stones and ${level.pale} pale '
          'is ${level.floor} lamps, and ${level.lit} is under it. Seven being '
          'a prime is the reason. Step round the hoop by the gap between the '
          'two dark stones and the step passes through every hole before it '
          'comes back, so the pale stones lie in runs along that walk, and '
          'the hole one step past the end of a run lights while holding no '
          'pale stone of its own. That gives the pale stones plus at least '
          'one more. None of the ${level.boards} boards with these stones '
          'gets under ${level.floor}. On a hoop of six holes the same stones '
          'leave four lamps nine boards over, because a step of two or three '
          'goes round only part of the way.';
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
              done ? 'Lit.' : 'Under the floor.',
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
                  onPressed: onHoop,
                  child: const Text('The hoop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
