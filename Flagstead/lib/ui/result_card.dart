import 'package:flutter/material.dart';

import '../hall/play.dart';
import '../hall/rules.dart';
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

  /// The standing record, after this standing counted.
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
      words = 'A hall ${play.wide} by ${play.tall} with the peg at '
          '(${play.px}, ${play.py}): the posts are '
          '${Rules.tellSquares(play.squares)} paces off, and both pairs add '
          'to ${play.acrossOne}. One of ${level.ways} '
          'standing${level.ways == 1 ? '' : 's'} of the 11,025 that land the '
          'ask, in ${play.moves} tap${play.moves == 1 ? '' : 's'} against '
          'the ${level.fewest} the cheapest takes.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The two sums never agree on a leaning hall. Multiply the '
          'brackets out and the peg drops away from the difference '
          'altogether: what is left is twice the lean times the width, which '
          'here is ${play.apart}, and the peg is nowhere in it. You have '
          'tried ${play.seen.length} standing${play.seen.length == 1 ? '' : 's'} '
          'and every one of them was ${play.apart} apart. The sweep of all '
          '11,025 standings finds the same on every one, at leans of one, '
          'two and three alike, and nought only when the corners are square.';
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
              done ? 'Both the same.' : 'The lean will not have it.',
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

/// How the two sums stand, for a chip.
String sumsChip(Play play) => play.agrees
    ? 'both ${play.acrossOne}'
    : '${play.acrossOne} against ${play.acrossTwo}';
