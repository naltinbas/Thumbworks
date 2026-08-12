import 'package:flutter/material.dart';

import '../hill/play.dart';
import 'palette.dart';

/// The card that ends a hill, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onSide,
  });

  final Play play;

  /// The standing record, after this planting counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSide;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? '${play.patches} patch${play.patches == 1 ? '' : 'es'}, '
            'as asked, in ${play.moves} '
            'replanting${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve replantings and the count never came even. It '
            'never will: the rim carries one bracken-gorse edge, '
            'and every planting\'s patch count shares that walk\'s '
            'parity. Odd, every time.';
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
              done ? 'Planted.' : 'The hill stays odd.',
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
                  onPressed: onSide,
                  child: const Text('The hillside'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
