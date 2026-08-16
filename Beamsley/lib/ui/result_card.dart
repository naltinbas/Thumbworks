import 'package:flutter/material.dart';

import '../shadow/play.dart';
import '../shadow/rules.dart';
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
      words = 'Pegs ${pegWords(play)} cast ${castWords(play)}: the shadows at ${shadowWords(play)}, '
          'the sides meeting at ${meetWords(play)}, all three on ${axisWords(play)}, by the crossings and by the fractions; '
          'one of ${_commas(level.ways)} setting${level.ways == 1 ? '' : 's'} of the 511,488; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final m = play.meetings;
      words = 'No casting bends the axis. It never will: Desargues proved in 1639 that two triangles drawn from one '
          'point meet side to side in three places on one line, and the sweep of all 511,488 settings finds the three '
          'meetings on one line every time, whether they stand somewhere or run off to infinity.'
          '${m == null ? '' : ' Here they meet at ${meetWords(play)}, all three on ${axisWords(play)}.'}';
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
              done ? 'Cast.' : 'Straight, every time.',
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

/// The pegs in words: '(1, 0), (0, 1), (-1, -1)'.
String pegWords(Play play) => play.pegs.map(Rules.tellPeg).join(', ');

/// The casts in words: '2, 3 and -1'.
String castWords(Play play) => '${play.casts[0]}, ${play.casts[1]} and ${play.casts[2]}';

/// The shadow pegs in words.
String shadowWords(Play play) => play.shadows.map(Rules.tellPeg).join(', ');

/// The three meetings in words.
String meetWords(Play play) => play.meetings!.map(Rules.tellPoint).join(', ');

/// The axis in words.
String axisWords(Play play) {
  final axis = play.axis;
  return axis == null ? 'no line at all' : Rules.tellLine(axis);
}

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
