import 'package:flutter/material.dart';

import '../rung/play.dart';
import '../rung/rules.dart';
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

  /// The standing record, after this measure counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final miss = play.miss;
      words = 'Side ${play.side}, diagonal ${play.diagonal}: ${play.diagonal} squared is ${Rules.commas(play.diagonal * play.diagonal)} and twice '
          '${play.side} squared ${Rules.commas(2 * play.side * play.side)}, ${miss.abs()} ${miss > 0 ? 'over' : 'under'}, and ${play.diagonal} over '
          '${play.side} is ${(play.diagonal / play.side).toStringAsFixed(5)}, ${play.off.toStringAsFixed(5)} ${play.diagonal / play.side > 1.4142135 ? 'over' : 'under'} '
          'the true diagonal${play.onLadder ? ', a rung of the ladder' : ''}; ${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No whole side has a whole diagonal. It never will: the diagonal squared would be '
          'twice the side squared, so even, so the diagonal even and its square a multiple of '
          'four, so the side squared even and the side even, and halving both gives a smaller '
          'pair of the same kind, which cannot go on for ever; the top rung, 99 and 70, misses '
          'by one, 9,801 to 9,800, and the sweep of all 14,400 pairs finds no true diagonal.';
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
              done ? 'Measured.' : 'Never a whole diagonal.',
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
