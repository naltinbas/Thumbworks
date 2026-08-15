import 'package:flutter/material.dart';

import '../show/play.dart';
import '../show/rules.dart';
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

  /// The standing record, after this show counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final w = play.winner;
    final ring = play.ringOrder;
    final words = done
        ? '${ring != null ? 'The majority runs in a ring, ${ring.map((p) => Rules.pieNames[p]).join(' over ')} over ${Rules.pieNames[ring.first]}, though every judge ranked the pies straight' : '${_cap(Rules.pieNames[w!])} beats every other pie head to head, ${Rules.firsts(play.profile).contains(w) ? 'with ${play.points[w]} points against ${play.points.reduce((a, b) => a > b ? a : b)} for the top on points' : 'and is first on no ballot'}'}; '
            '${play.moves} move${play.moves == 1 ? '' : 's'}.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twenty-four moves, and every pie that beat both others was somebody\'s '
            'first. It always is: first on no ballot, it would lie under one of the '
            'other two on each ballot, so the ballots ranking it over one and those '
            'ranking it over the other would come to three at most between them, and '
            'beating both takes two of each, four.';
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
              done ? 'Judged.' : 'The modest winner never comes.',
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
