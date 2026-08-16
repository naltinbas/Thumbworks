import 'package:flutter/material.dart';

import '../pair/play.dart';
import '../pair/rules.dart';
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

  /// The standing record, after this pair counted.
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
      words = '${play.x} and ${play.y}, sum ${play.sum} and product ${play.product}: ${saidWords(play)}, by the four things asked and by the narrowing of the whole set; '
          'one of ${_commas(level.ways)} pair${level.ways == 1 ? '' : 's'} of the 2,352; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final split = Rules.primeSplit(play.sum);
      words = 'No even sum lets S say she knew P did not know. It never will: every even sum from 8 to 100 splits '
          'into two different primes, as Goldbach guessed and the sieve checks, and the product of two primes '
          'splits no other way, so P would know at once from that split; 6 splits only into 2 and 4, whose '
          'product tells P too, and 4 does not split at all. The sieve of all 2,352 pairs finds 145 whose sum '
          'lets S speak, every one of them odd.'
          '${split == null ? '' : ' Here ${play.sum} is ${split.$1} + ${split.$2}, and ${split.$1 * split.$2} tells P.'}';
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
              done ? 'Said.' : 'Two primes, every time.',
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

/// The four things said, as they stand, in words: 'P in the dark, S
/// knew it, P now knows, S now knows too', cut where they stop holding.
String saidWords(Play play) {
  final (one, two, three, four) = play.said;
  if (!one) return 'the product tells P at once';
  final parts = ['P in the dark'];
  if (two) parts.add('S knew it');
  if (three) parts.add('P now knows');
  if (four) parts.add('S now knows too');
  if (!two) parts.add('but S could not have known');
  return parts.join(', ');
}

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
