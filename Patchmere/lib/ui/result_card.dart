import 'package:flutter/material.dart';

import '../quilt/play.dart';
import 'palette.dart';


/// The card that ends a cording, either way.
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

  /// The standing record, after this cording counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final held = play.level.winnable && !done;
    final words = done
        ? 'You sewed the last patch; ${play.moves} '
            'patch${play.moves == 1 ? '' : 'es'} of yours.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : held
            ? 'The house sewed the last patch. The tree read the start as '
                'yours to sew last, so the thread was there to keep.'
            : 'The quilt is sewn out and the house sewed last, as it always '
                'will: every patch of yours has a free mirror across the '
                'middle on an even-by-even quilt, and the house sews it, so '
                'you are the one who runs out.';
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
              done
                  ? 'Landed.'
                  : held
                      ? 'The house sewed last.'
                      : 'The house never runs out.',
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
