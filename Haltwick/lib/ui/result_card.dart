import 'package:flutter/material.dart';

import '../wait/play.dart';
import '../wait/rules.dart';
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

  /// The standing record, after this timetable counted.
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
      words = 'Gaps ${Rules.tellGaps(play.gaps)}: average wait ${Rules.tell(play.wait)} minutes, by the gaps and by the minutes, '
          '${play.wait == Rules.fairWait ? 'the fair wait itself' : '${Rules.tell(play.over)} over the fair 9 1/2'}, the longest wait ${play.longest}; '
          'one of ${_commas(level.ways)} timetable${level.ways == 1 ? '' : 's'} of the 1,711; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No timetable waits under 9 1/2 minutes on average. It never will: the waiting in an hour adds up gap by gap '
          'to half of each gap squared less half the gap, and three gaps adding to sixty square to 1,200 at least, since '
          'the average of squares is never below the square of the average, equal gaps alone touching it; so the '
          'waiting is 570 minutes at least, 9 1/2 a passenger, and the sweep of all 1,711 timetables finds none under it.'
          ' Here the gaps ${Rules.tellGaps(play.gaps)} wait ${Rules.tell(play.wait)}${play.wait == Rules.fairWait ? ', the fair wait itself, as low as it goes' : ''}.';
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
              done ? 'Timetabled.' : 'Never under, always.',
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

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
