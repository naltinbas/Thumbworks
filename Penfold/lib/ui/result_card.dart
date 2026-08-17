import 'package:flutter/material.dart';

import '../fold/play.dart';
import '../fold/rules.dart';
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

  /// The standing record, after this call counted.
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
      words = 'The call ${Rules.tellCall(play.call)} gathers the flock in '
          'field ${Rules.tellField(Rules.standing(play.flock).first)}, in '
          '${play.moves} whistle${play.moves == 1 ? '' : 's'} against the '
          '${level.length} the fold needs. '
          '${level.ways} of the ${level.calls} calls of ${level.length} '
          '${level.ways == 1 ? 'gathers' : 'gather'} it, and no shorter call '
          'does.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No call gathers this fold, however long. Both whistles send '
          'each field to a field of its own, so no two sheep ever land '
          'together and the flock stays four wide: you have blown '
          '${play.moves} and it is still standing in '
          '${Rules.standing(play.flock).map(Rules.tellField).join(', ')}. '
          'Cerny\'s test says the same from the other end, since the sheep '
          'in fields 1 and 3 can never be brought together, and of all '
          '65,536 folds of four fields and two whistles the 14,016 that '
          'cannot be gathered are exactly the ones with such a pair.';
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
              done ? 'Gathered.' : 'Four wide, and staying that way.',
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

/// How wide the flock stands, for a chip.
String spreadChip(Play play) => play.spread == 1
    ? 'all in one field'
    : 'spread over ${play.spread} fields';
