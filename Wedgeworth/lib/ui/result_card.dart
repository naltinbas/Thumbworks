import 'package:flutter/material.dart';

import '../wedge/play.dart';
import '../wedge/rules.dart';
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

  /// The standing record, after this corner counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final (v, e, f) = play.euler ?? (0, 0, 0);
    final words = done
        ? '${_cap(Rules.count(play.faces))} ${Rules.face(play.sides, plural: true)} make '
            '${Rules.degrees(play.sum)} degrees, ${Rules.degrees(play.gap)} to spare, and close '
            '${play.solid}: $f faces, $e edges and $v corners, and $v - $e + $f is 2; '
            '${play.moves} setting${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve settings, and no corner of hexagons. There never is one: a '
            'hexagon\'s corner is 120 degrees, three make the full 360 and lie flat, '
            'as the bees\' comb does, and four or more overlap; and three faces are '
            'the fewest a corner can have.';
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
              done ? 'Closed.' : 'The comb lies flat.',
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

String _cap(String s) => '${s[0].toUpperCase()}${s.substring(1)}';
