import 'package:flutter/material.dart';

import '../road/play.dart';
import '../road/rules.dart';
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

  /// The standing record, after this setting counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final String words;
    if (done) {
      final (top, bottom, across) = play.settled;
      final split = play.open && across == play.crowd
          ? 'all ${Rules.tell(across)} go top, across and bottom'
          : play.open
              ? '${Rules.tell(top)} go by the top, ${Rules.tell(bottom)} by the bottom and ${Rules.tell(across)} across'
              : '${Rules.tell(top)} go by the top and ${Rules.tell(bottom)} by the bottom';
      final other = play.open ? play.journeyShut : play.journeyOpen;
      words = '${Rules.tell(play.crowd)[0].toUpperCase()}${Rules.tell(play.crowd).substring(1)} drivers, the shortcut ${play.open ? 'open' : 'shut'}: $split, '
          'and everyone takes ${play.journey} minutes, ${other == play.journey ? 'the same as' : '${(play.journey - other).abs()} ${play.journey > other ? 'more' : 'fewer'} than'} with it ${play.open ? 'shut' : 'open'}; '
          'one of ${play.level.ways} setting${play.level.ways == 1 ? '' : 's'} of the ${Rules.settings}; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Past thirty hundred the open shortcut never helps. It never will: under forty-five hundred every '
          'driver goes across, since that way beats either old way whatever the others do, and takes twice '
          'the crowd in minutes, more than 45 plus half the crowd once the crowd tops thirty; from forty-five '
          'hundred on the settled journey is 90, more than 45 plus half the crowd until the crowd would top '
          'ninety. Here ${Rules.tell(play.crowd)} take ${play.journeyOpen} with it open and ${play.journeyShut} with it shut, and the sweep of every '
          'crowd on the dial finds none past thirty helped.';
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
              done ? 'Settled.' : 'A road that slows everyone.',
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
