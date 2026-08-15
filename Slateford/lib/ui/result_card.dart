import 'package:flutter/material.dart';

import '../slate/play.dart';
import 'palette.dart';
import 'slateview.dart';

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
        ? 'The slate stands as asked; ${play.moves} '
            'move${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : held
            ? (play.lost
                ? 'The book made three in a row. The tree read the start as '
                    '${valueWords(Play.of(play.level).value)} from your side, so the '
                    'thread was there to keep.'
                : 'The slate filled level, and the win asked was not made. It was '
                    'there: the tree read the start as a win for you.')
            : 'The slate is played out and the book stands level or better, as '
                'it always will: it keeps the tree\'s word at every move, and '
                'the tree reads the open slate level. If noughts had a winning '
                'way, crosses could take it first, so neither side can be forced '
                'to lose.';
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
                      ? 'The book held it.'
                      : 'The book never loses.',
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
