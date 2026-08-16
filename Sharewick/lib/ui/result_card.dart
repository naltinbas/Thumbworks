import 'package:flutter/material.dart';

import '../trio/play.dart';
import '../trio/rules.dart';
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

  /// The standing record, after this family counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      final apart = play.apart;
      words = '${Rules.tell(play.family)}: ${play.size} trios, '
          '${apart.isEmpty ? 'every two sharing a friend, by every pair looked at and by one of each missing pair' : '${apart.length} pairs apart, ${apartWords(apart)}'}; '
          'hands ${handWords(play)}; '
          'one of ${_commas(level.ways)} famil${level.ways == 1 ? 'y' : 'ies'} of the 1,048,576; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final apart = play.apart;
      words = 'No eleven trios all share a friend. It never will: two trios of six friends miss each other only '
          'when one is the other three, so the twenty trios fall into ten missing pairs, and a family in which '
          'every two share takes one trio of each pair at most, ten; the sweep of all 1,048,576 families finds '
          '59,049 sharing throughout, 1,024 of ten trios and none of eleven.'
          '${apart.isEmpty ? '' : ' Here ${play.size} trios have ${apart.length} pair${apart.length == 1 ? '' : 's'} apart, ${apartWords(apart)}.'}';
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
              done ? 'Picked.' : 'Ten at most, always.',
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

/// Pairs apart in words: 'ABC and DEF, ABD and CEF', two at most and
/// 'and more' past that.
String apartWords(List<(int, int)> apart) {
  final told = apart.take(2).map((p) => '${Rules.nameOf(p.$1)} and ${Rules.nameOf(p.$2)}').join(', ');
  return apart.length > 2 ? '$told and ${apart.length - 2} more' : told;
}

/// The hands in words: 'A 5, B 5, C 5, D 5, E 5, F 5', or 'five each'
/// when they are all alike.
String handWords(Play play) {
  final h = play.hands;
  if (h.every((x) => x == h.first)) return '${h.first} each';
  return [for (var f = 0; f < Rules.friends; f++) '${Rules.names[f]} ${h[f]}'].join(', ');
}

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
