import 'package:flutter/material.dart';

import '../cask/play.dart';
import '../cask/rules.dart';
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
      words = 'The run ${Rules.tellRun(play.first, play.last)}, '
          '${play.casks} casks, comes to ${Rules.tellTotal(play.total)} of a '
          'barrel, added '
          'cask by cask and again over a common bottom; '
          '${play.level.ways == 1 ? 'the only run' : 'one of ${play.level.ways} runs'} '
          'of the 1,770 that ${play.level.ways == 1 ? 'lands' : 'land'} it; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final deepest = play.deepest.first;
      words = 'No run of casks comes to a whole barrel. The ${Rules.ordinal(deepest)} '
          'cask of this run holds more twos than any other and nothing else '
          'in the run holds as many, so over a common bottom it alone divides '
          'in an odd number of times and every other divides in an even '
          'number. The total is odd over even, here '
          '${Rules.tellTotal(play.total)}, and an odd '
          'over an even is not a whole number. All 1,770 runs the cellar '
          'allows were poured before the sham was built and not one of them '
          'came out whole.';
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
              done ? 'Poured.' : 'Never whole.',
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
