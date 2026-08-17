import 'package:flutter/material.dart';

import '../hat/play.dart';
import '../hat/rules.dart';
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

  /// The standing record, after this agreement counted.
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
      final lost = play.losses;
      words = 'The village wins ${play.wins} of the eight hattings and loses '
          '${lost.isEmpty ? 'none' : lost.join(' and ')}. The agreement '
          'calls for ${play.words} word${play.words == 1 ? '' : 's'}, and '
          'the same count of wrong words falls on the hattings it loses. '
          'One of ${level.ways} agreements of the 531,441 that land the ask, '
          'in ${play.moves} tap${play.moves == 1 ? '' : 's'} against the '
          '${level.fewest} the cheapest takes.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Seven is not to be had. Every word an agreement calls for is '
          'right on one of the two hattings its sight allows and wrong on '
          'the other, so the wrong words are as many as the words: this one '
          'calls for ${play.words} and risks ${play.wrongs}. A hatting the '
          'village loses can swallow at most three wrong words, one from '
          'each villager, so winning seven leaves room for three words in '
          'all, and three words win at most three hattings. The sweep of all '
          '531,441 agreements finds four that win six, and nothing above it.';
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
              done ? 'Agreed.' : 'Six is the ceiling.',
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

/// How the village fares, for a chip.
String winsChip(Play play) => '${play.wins} of 8 won';

/// What the agreement risks, for a chip.
String wordsChip(Play play) =>
    '${play.words} word${play.words == 1 ? '' : 's'}, '
    '${play.wrongs} wrong';

/// Who says what, for the verdict.
String sayWords(Play play, int who, int sight) =>
    '${Rules.tellVillager(who)} on ${Rules.tellSight(sight)}: '
    '${Rules.tellSay(play.agreement[who][sight])}';
