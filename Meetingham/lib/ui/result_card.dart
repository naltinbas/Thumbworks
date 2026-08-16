import 'package:flutter/material.dart';

import '../lane/play.dart';
import '../lane/rules.dart';
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

  /// The standing record, after this laning counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    final (nx, ny, den) = play.meetingPoint;
    final at = den == 1 ? '($nx, $ny)' : '($nx/$den, $ny/$den)';
    if (done) {
      words = 'Gates D ${Rules.ratio(play.d)}, E ${Rules.ratio(play.e)}, F ${Rules.ratio(play.f)}: the three ratios multiply to 1, and the '
          'lanes meet at $at, found by crossing; one of ${play.level.ways} settings of 1,331; ${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final (pn, pd) = play.product;
      words = 'The three lanes never meet with every gate a third along the same way round. They never will: '
          'each gate cuts its side 1:2, and 1:2 times 1:2 times 1:2 is 1:8, not 1:1; here the product is '
          '$pn to $pd, the lanes from A and B cross at $at, and the lane from C misses it; the sweep of all '
          '1,331 settings finds 31 meetings, every one with a gate at a middle.';
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
              done ? 'Met.' : 'One to eight, never one.',
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
