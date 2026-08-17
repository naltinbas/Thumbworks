import 'package:flutter/material.dart';

import '../rick/play.dart';
import '../rick/rules.dart';
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

  /// The standing record, after this field counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final side = play.markerSides.first;
    final acres = play.halfAcres;
    final String words;
    if (done) {
      words = 'Posts at ${Rules.tellPosts(play.posts)}, a field of '
          '${acres.isEven ? '${acres ~/ 2}' : '$acres halves of an'} '
          '${acres.isEven && acres ~/ 2 == 1 ? 'acre' : 'acres'}. Its three '
          'rick markers stand the same distance apart, that distance squared '
          'being $side, worked out in fractions and roots of three and '
          'settled twice: by measuring the three gaps, and by turning one '
          'marker sixty degrees about another onto the third. One of '
          '${play.level.ways} '
          '${play.level.ways == 1 ? 'field' : 'fields'} of the 2,148 that '
          '${play.level.ways == 1 ? 'lands' : 'land'} it; ${play.moves} '
          'post${play.moves == 1 ? '' : 's'} moved.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'The markers are never uneven. Raising an even triangle on a '
          'side turns that side by sixty degrees, and the sine of sixty is '
          'half the root of three, so every marker sits at a place of the '
          'form a and b roots of three with a and b exact fractions. Two such '
          'places match only when both halves do, since the root of three is '
          'not a fraction. Here the three gaps come out at $side apiece. All '
          '2,148 fields the green holds were measured before the sham was '
          'built, with the ricks raised outward and again inward, and the '
          'markers came out evenly spread on every one.';
    }
    return Card(
      color: Palette.board,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: done ? Palette.good : Palette.bad, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              done ? 'Raised.' : 'Even, wherever the posts stand.',
              style: TextStyle(
                color: done ? Palette.good : Palette.bad,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(words,
                style: const TextStyle(color: Palette.ink, fontSize: 14)),
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
