import 'package:flutter/material.dart';

import '../odd/play.dart';
import '../odd/rules.dart';
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

  /// The standing record, after this run counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final told = play.count <= 8 ? Rules.told(play.first, play.count) : '${play.first} + ${play.first + 2} + ... + ${play.first + 2 * (play.count - 1)}';
      words = '$told = ${play.sum}, ${play.count} odd number${play.count == 1 ? '' : 's'}: '
          '${play.inner == 0 ? '${play.count} squared' : '${play.outer} squared less ${play.inner} squared, ${play.outer * play.outer} less ${play.inner * play.inner}'}; '
          'one of ${play.level.ways} run${play.level.ways == 1 ? '' : 's'} of the 1,000; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No run of consecutive odd numbers makes thirty. It never will: an odd count of odd numbers adds '
          'to an odd number, and an even count pairs off, each pair of neighbouring odd numbers a multiple '
          'of four, so the sum is a multiple of four, and thirty is neither, two past a multiple of four; '
          'here ${Rules.told(play.first, play.count)} makes ${play.sum}, and the sweep of all 1,000 runs on the dials makes 28 and 32 and never 30.';
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
              done ? 'Added up.' : 'Two past a multiple of four.',
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
