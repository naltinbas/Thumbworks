import 'package:flutter/material.dart';

import '../party/play.dart';
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

  /// The standing record, after this party counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final what = play.level.days == 12 ? 'a shared birth month' : 'a shared birthday';
    final words = done
        ? '${play.guests} guests make $what ${play.inHundred} in a hundred, and '
            '${play.guests - 1} make it ${_short(play)}; '
            '${play.moves} press${play.moves == 1 ? '' : 'es'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twenty-four presses, and never certain. Under 366 it never is: 365 guests '
            'can have one birthday each, and the chance of no two sharing, 365 times '
            '364 and on down over 365 to the 365th, is a number 779 digits long over '
            'one 936 digits long, small past telling and not nought; the 366th guest '
            'has no day left.';
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
              done ? 'Gathered.' : 'Never certain under 366.',
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

/// The chance one guest fewer had, in a hundred.
String _short(Play play) => play.guests <= 1 ? 'nought' : Play.standing(play.level, play.guests - 1).inHundred;
