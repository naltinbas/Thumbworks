import 'package:flutter/material.dart';

import '../third/play.dart';
import 'palette.dart';

/// The card that ends a hand, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onLeton,
  });

  final Play play;

  /// The standing record, after this dialling counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onLeton;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final held = play.thirds.length;
    final words = done
        ? 'Exactly $held third${held == 1 ? '' : 's'} stand'
            '${held == 1 ? 's' : ''}, census and remainders '
            'agreeing; ${play.moves} tap${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Fifteen taps taken, and the empty hand never came. '
            'It never will: a remainder shown three times sums '
            'to a three-times, and failing that all three '
            'remainders show, and nought, one and two make '
            'three.';
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
              done ? 'Dialled home.' : 'Five stones always carry one.',
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
                  onPressed: onLeton,
                  child: const Text('The leton'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
