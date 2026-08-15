import 'package:flutter/material.dart';

import '../fuse/play.dart';
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
    final missed = play.level.winnable && !done;
    final words = done
        ? 'The time is struck to the burnout; ${play.moves} ends lit.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : missed
            ? 'The time went by unstruck; ${play.level.ways} of the ${play.level.plans} '
                'plans of lighting strike it, and the show-me knows one.'
            : 'The first burnout has come and gone, and it came at thirty at the '
                'soonest, as it always does: a fresh fuse takes an hour from one '
                'end and half from both, and nothing can be lit before that but at '
                'the start. Two fuses strike 30, 45, 60, 90 and 120 and nothing '
                'else.';
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
                  : missed
                      ? 'The time went by.'
                      : 'Twenty is never struck.',
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
