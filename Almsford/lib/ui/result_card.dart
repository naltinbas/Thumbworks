import 'package:flutter/material.dart';

import '../alms/play.dart';
import '../alms/rules.dart';
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

  /// The standing record, after this share-out counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      words = 'The bins stand ${Rules.tellBins(play.bins)}, which is the shape '
          '${Rules.tellShape(play.shape)}, and their running totals are '
          '${play.running.join(', ')}; one of ${play.level.ways} '
          '${play.level.ways == 1 ? 'arrangement' : 'arrangements'} of the '
          '1,001 that ${play.level.ways == 1 ? 'stands' : 'stand'} that way; '
          '${play.moves} share${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
          '${play.settled ? ' Nothing can move from here: no bin is two ahead of another.' : ''}';
    } else {
      words = 'A share takes a measure out of the fuller bin, so the fullest '
          'bin never rises. Nor do the two fullest together, nor the three, '
          'and so on down. The bins opened at nine in the fullest and stand '
          'at ${play.shape.first} now, with running totals '
          '${play.running.join(', ')} against the ${Rules.grain} the one heap '
          'wants at the head of its own. Once grain has been spread it cannot '
          'be gathered. Every share-out from every one of the 1,001 '
          'arrangements was walked before the sham was built, and the shapes '
          'a walk reaches are exactly the ones whose running totals are no '
          'greater.';
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
              done ? 'Shared.' : 'The fullest never rises.',
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
