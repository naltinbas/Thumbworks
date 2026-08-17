import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import 'palette.dart';

/// The card that ends an ask, however it ended.
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
    final String head, words;
    if (done) {
      head = 'Away.';
      words = 'The out-train reads ${Rules.tellTrain(play.out)}, and the '
          'siding made it: one of ${play.level.ways} '
          '${play.level.ways == 1 ? 'out-train' : 'out-trains'} of the 132 '
          'that ${play.level.ways == 1 ? 'lands' : 'land'} the ask, out of '
          'the 720 orders six wagons can stand in; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else if (play.wedged) {
      head = 'Wedged.';
      words = 'The ask cannot be landed from here. '
          '${play.siding.isEmpty ? 'The siding is empty' : 'The siding holds ${Rules.tellTrain(play.siding)}, with ${play.siding.last} at the points'}, '
          '${play.out.isEmpty ? 'and nothing has gone out yet' : 'and the out-train reads ${Rules.tellTrain(play.out)}'}. '
          'Only the wagon at the points can be sent, so anything behind it '
          'has to follow it out. Take a tap back, or start again.';
    } else {
      head = 'The points say no.';
      final atPoints = play.siding.isEmpty ? null : play.siding.last;
      words = 'No siding can send wagon 3 out first and then wagon 1 before '
          'wagon 2. Getting 3 out first means shunting 1 and 2 onto the '
          'siding, 1 first and 2 behind it, which leaves 2 at the points'
          '${atPoints == 2 ? ', where it stands now' : ''}. '
          'Only the wagon at the points can be sent, so 2 leaves before 1 '
          'and the order 3, 1, 2 is out of reach. Every order of every train '
          'up to eight wagons was run before the sham was built, and the '
          'yard made exactly the ones with no wagon followed by a smaller '
          'one and then by one in between.';
    }
    final wrong = !done;
    return Card(
      color: Palette.board,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: wrong ? Palette.bad : Palette.good, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              head,
              style: TextStyle(
                color: wrong ? Palette.bad : Palette.good,
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
