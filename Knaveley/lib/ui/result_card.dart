import 'package:flutter/material.dart';

import '../isle/play.dart';
import '../isle/rules.dart';
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

  /// The standing record, after this naming counted.
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
      words = '${Rules.tellNaming(play.kinds)}: every telling holds, the '
          'knights\' true and the knaves\' false. '
          '${level.ways == 1 ? 'It is the only naming of the ${level.namings} that does' : 'It is one of ${level.ways} namings of the ${level.namings} that do'}, '
          'in ${play.moves} tap${play.moves == 1 ? '' : 's'} against the '
          '${level.fewest} the nearest takes.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No naming holds these tellings, and the first one is why. '
          '${Rules.tellName(0)} says "I am a knave". A knight cannot say it, '
          'since it would be false; a knave cannot say it either, since it '
          'would be true. So whatever the others are, '
          '${Rules.tellName(0)} is caught out, and all ${level.namings} '
          'namings fall with them. You have tried ${play.seen.length} of '
          'them.';
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
              done ? 'Every telling holds.' : 'Nobody can say it.',
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

/// How many are caught out, for a chip.
String caughtChip(Play play) {
  final many = play.caught.length;
  if (many == 0) return 'nobody is caught out';
  return '$many caught out';
}
