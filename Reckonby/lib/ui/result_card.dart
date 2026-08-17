import 'package:flutter/material.dart';

import '../count/play.dart';
import '../count/rules.dart';
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

  /// The standing record, after this reading counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final parts = [
        for (var k = Rules.wheels; k >= 1; k--)
          if (play.wheels[k - 1] > 0)
            '${play.wheels[k - 1]} times ${Rules.worth(k)}',
      ];
      words = 'The wheels stand ${Rules.tellWheels(play.wheels)}, which is '
          '${parts.join(' and ')}, and the house reads ${play.reading}. No '
          'other setting of the wheels reads it, and none of the 720 reads '
          'the same number twice; ${play.moves} '
          'turn${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The house stops at ${Rules.most}. Every wheel at its top is '
          'worth k times k factorial, which is (k + 1) factorial less k '
          'factorial, so the five of them fold up to 6 factorial less one '
          'and there is nothing above it to read. The wheels stand at '
          '${Rules.tellWheels(play.wheels)} and the house reads '
          '${play.reading}, ${play.under} under the top. All 720 settings '
          'were read before the sham was built and they give the numbers 0 '
          'to ${Rules.most}, each of them once.';
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
              done ? 'Read.' : 'The house stops at 719.',
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
