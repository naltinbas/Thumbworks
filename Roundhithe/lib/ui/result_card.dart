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

  /// The standing record, after this plan counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final trip = play.trip;
    final String words;
    if (done) {
      words = '${Rules.tell(play.roads)}: ${play.roadCount} roads, ${degreeWords(play)}; '
          '${trip == null ? 'no round trip' : 'a round trip, ${tripWords(trip)}'}, by the walk and by the table; '
          'one of ${level.ways} plan${level.ways == 1 ? '' : 's'} of the 32,768; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No plan gives every village three roads and no round trip. It never will: Dirac proved in 1952 '
          'that when every village has half the others as neighbours at least, a longest walk that repeats no '
          'village closes into a ring and takes in whatever it missed; the sweep of all 32,768 road-plans finds '
          '1,858 with three roads or more at every village, and a round trip on every one.'
          '${trip == null ? '' : ' Here ${Rules.tell(play.roads)} has one, ${tripWords(trip)}.'}';
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
              done ? 'Laid.' : 'Round, every time.',
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

/// The roads at each village, in words: 'every village 3', or 'A 4,
/// B 4, C 4, D 4, E 5, F 1'.
String degreeWords(Play play) {
  final d = play.degrees;
  if (d.every((x) => x == d.first)) return 'every village ${d.first}';
  return [for (var v = 0; v < Rules.villages; v++) '${Rules.names[v]} ${d[v]}'].join(', ');
}

/// A trip in words: 'A D B E C F A'.
String tripWords(List<int> trip) => '${trip.map((v) => Rules.names[v]).join(' ')} A';
