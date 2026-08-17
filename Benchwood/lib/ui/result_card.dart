import 'package:flutter/material.dart';

import '../bench/play.dart';
import '../bench/rules.dart';
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

  /// The standing record, after this run counted.
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
      words = 'The card is worked out in ${play.walks} walks, which is the '
          'fewest there is. ${level.ways} of the ${level.runs} ways of '
          'playing this card '
          '${level.ways == 1 ? 'keeps' : 'keep'} to ${level.walks}, and '
          'Belady\'s rule finds one of them every time by carrying back the '
          'tool whose next call is furthest off.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else if (level.winnable) {
      words = 'The card is worked out, but in ${play.walks} walks and the ask '
          'wants ${level.walks}. Carrying back the tool whose next call is '
          'furthest off would have done it: only ${level.ways} of the '
          '${level.runs} ways of playing this card '
          '${level.ways == 1 ? 'keeps' : 'keep'} to ${level.walks}, and that '
          'rule finds one of them.';
    } else {
      words = 'The card is worked out in ${play.walks} walks, and three is '
          'not possible. Three different tools have to be fetched at least '
          'once each, so three is a floor to begin with. After the third '
          'call the bench holds two of the three, so one is down in the '
          'store, and the last three calls ask for all three again: that is '
          'a fourth walk whatever was carried back. None of the '
          '${level.runs} ways of playing the card does it in three, and the '
          'fewest is ${level.fewest}.';
    }
    final headline = done
        ? 'Fewest walks.'
        : level.winnable
            ? 'Too many walks.'
            : 'Four is the floor.';
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
              headline,
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

/// What the bench holds, for a chip.
String benchChip(Play play) => play.bench.isEmpty
    ? 'the bench is bare'
    : 'bench ${play.bench.map(Rules.tellTool).join(' ')}';
