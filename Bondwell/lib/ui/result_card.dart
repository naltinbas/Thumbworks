import 'package:flutter/material.dart';

import '../bond/play.dart';
import '../bond/rules.dart';
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

  /// The standing record, after this division counted.
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
      words = '${level.estate} coins go ${play.purses.join(', ')}, which is '
          '${play.purses.map(Rules.tellZuz).join(', ')} zuz against bonds of '
          '${Rules.bonds.join(', ')}. Every pair splits its own coins by the '
          'garment rule, so all three scales hang level, and this is the '
          'only one of the ${level.divisions} divisions that does it, in '
          '${play.moves} tap${play.moves == 1 ? '' : 's'} against the '
          '${level.fewest} the dials need.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No division of ${level.estate} coins puts the longest bond '
          'ahead of the shortest with every scale level, and none ever will. '
          'Twelve coins is under every bond, so no heir can concede a coin '
          'to another: whatever two of them hold between them, both still '
          'claim the whole of it, and the garment rule halves what is '
          'contested. Even between every pair leaves the three purses equal, '
          'and equal purses put nobody ahead. The sweep of all '
          '${level.divisions} divisions finds the one that levels the '
          'scales, four coins each, and it is the same for every heir.';
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
              done ? 'All three level.' : 'The long bond gains nothing.',
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

/// How many scales hang level, for a chip.
String scalesChip(Play play) {
  final level = play.tilts.where((tilt) => tilt == 0).length;
  return '$level of 3 scales level';
}
