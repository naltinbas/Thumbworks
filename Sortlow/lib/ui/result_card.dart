import 'package:flutter/material.dart';

import '../mill/play.dart';
import 'palette.dart';

/// The card that ends a load, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onLow,
  });

  final Play play;

  /// The standing record, after this dialling counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onLow;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? '${play.number.toString().padLeft(4, '0')} stands '
            '${play.steps} turn${play.steps == 1 ? '' : 's'} from '
            'the stone, walk and table agreeing; ${play.moves} '
            'tap${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Sixteen taps taken, and the eighth turn never came. '
            'It never will: every allowed number arrives by the '
            'seventh, all 9,990 of them ground and counted.';
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
              done ? 'Dialled home.' : 'Seven is the whole road.',
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
                  onPressed: onLow,
                  child: const Text('The low'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
