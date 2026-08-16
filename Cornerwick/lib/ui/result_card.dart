import 'package:flutter/material.dart';

import '../square/play.dart';
import '../square/rules.dart';
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

  /// The standing record, after this four counted.
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
      final (a, _) = play.lengthsSquared!;
      final x = play.crossing;
      words = 'Pegs ${pegWords(play)}: centres at ${centreWords(play)}, the joins ${Rules.tellLength(a)} long both and at right angles, '
          'by the centres and by the turned join${x == null ? '' : ', crossing at ${crossingWords(play)}'}; '
          'one of ${_commas(level.ways)} four${level.ways == 1 ? '' : 's'} of the 227,952; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final ls = play.lengthsSquared;
      words = 'No four pegs skew the cross. It never will: each centre is the two ends of its side added and their gap '
          'turned a right angle, halved, and the join from the first centre to the third, written out from the four '
          'pegs and turned a right angle, is the join from the second to the fourth letter for letter, so the two are '
          'of one length and square to each other; the sweep of all 303,600 ordered fours of pegs finds it so on '
          'every one.'
          '${ls == null ? '' : ' Here the joins are ${Rules.tellLength(ls.$1)} long both, at right angles.'}';
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
              done ? 'Squared.' : 'Equal and square, always.',
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

/// The pegs in words: '(1, 1), (3, 1), (3, 3), (1, 3)'.
String pegWords(Play play) => play.pegs.map(Rules.tellPeg).join(', ');

/// The centres in words, in true units: '(2, 0), (4, 2), (2, 4), (0, 2)'.
String centreWords(Play play) => play.centres.map((c) => '(${_half(c.$1)}, ${_half(c.$2)})').join(', ');

/// The crossing in words: '(2, 2)'.
String crossingWords(Play play) {
  final x = play.crossing!;
  return '(${x.$1}, ${x.$2})';
}

String _half(int doubled) => doubled.isEven ? '${doubled ~/ 2}' : '$doubled/2';

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
