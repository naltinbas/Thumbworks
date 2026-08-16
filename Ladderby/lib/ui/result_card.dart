import 'package:flutter/material.dart';

import '../join/play.dart';
import '../join/rules.dart';
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

  /// The standing record, after this hexagon counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final (x, y, z) = play.crossings!;
      words = 'Bottom ${_pegs(Play.bottomNames, play.bottom)}, top ${_pegs(Play.topNames, play.top)}: '
          'X ${Rules.tell(x)}, Y ${Rules.tell(y)}, Z ${Rules.tell(z)}, by the general meeting of two lines and by the closed form, in a line; '
          'one of ${_commas(play.level.ways)} hexagon${play.level.ways == 1 ? '' : 's'} of the 14,168; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final c = play.crossings;
      words = 'No hexagon bends its line. It never will: Pappus of Alexandria proved around the year 340 '
          'that the three crossings of the cross-joins of any six points, three on each of two lines, lie on '
          'one line; the sweep of all 112,896 orderings of three pegs on each rail finds 85,008 whose joins '
          'all cross, 14,168 hexagons counted once each, and the three crossings in a line on every one.'
          '${c == null ? '' : ' Here X ${Rules.tell(c.$1)}, Y ${Rules.tell(c.$2)} and Z ${Rules.tell(c.$3)} lie in a line.'}';
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
              done ? 'Crossed.' : 'In a line, always.',
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

String _pegs(List<String> names, List<int> pegs) => [for (var i = 0; i < pegs.length; i++) '${names[i]} ${pegs[i]}'].join(', ');

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
