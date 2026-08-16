import 'package:flutter/material.dart';

import '../ticket/play.dart';
import '../ticket/rules.dart';
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

  /// The standing record, after this ticket counted.
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
      words = 'Ticket ${Rules.tell(play.digits)}: adds ${addWords(play)}, sum ${play.sum}, passes, by Luhn\'s doubling and by the table of doubles'
          '${play.swapPlaces.isNotEmpty ? '; a 0 by a 9, so swapped it passes still' : ''}'
          '${play.twinPlaces.isNotEmpty ? '; ${twinWords(play)}' : ''}; '
          'one of ${_commas(level.ways)} ticket${level.ways == 1 ? '' : 's'} of the 100,000; '
          '${play.moves} tap${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      final was = play.slipped ? play.before : null;
      words = 'No slip of one digit passes. It never will: in a plain place the sum moves by the difference of the two '
          'digits, one to nine, never a ten, and the doubling takes the ten digits to 0, 2, 4, 6, 8, 1, 3, 5, 7 and 9, '
          'every digit once, so a slip in a doubled place moves the sum too; the sweep of all 450,000 single slips of the '
          '10,000 passing tickets finds every one caught.'
          '${was == null ? '' : ' Here ${Rules.tell(was.digits)} passed with a sum of ${was.sum}, and one digit turned it to ${Rules.tell(play.digits)}, sum ${play.sum}.'}';
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
              done ? 'Passed.' : 'Caught, every time.',
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

/// What the digits add, in words: '4, 9, 9, 4 and 4'.
String addWords(Play play) {
  final a = play.adds;
  return '${a.sublist(0, a.length - 1).join(', ')} and ${a.last}';
}

/// The slipping twin in words: '3 3 in it, so 6 6 in their place passes still'.
String twinWords(Play play) {
  final i = play.twinPlaces.first;
  final a = play.digits[i];
  final pair = Rules.twinsUnseen.firstWhere((p) => p.$1 == a || p.$2 == a);
  final b = pair.$1 == a ? pair.$2 : pair.$1;
  return '$a $a in it, so $b $b in their place passes still';
}

String _commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
