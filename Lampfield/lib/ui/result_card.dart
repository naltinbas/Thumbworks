import 'package:flutter/material.dart';

import '../lamp/play.dart';
import '../lamp/rules.dart';
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

  /// The standing record, after this message counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onSham;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final lit = [
      for (var lamp = 1; lamp <= Rules.lamps; lamp++)
        if (play.message[lamp - 1] == 1) '$lamp',
    ];
    final String words;
    if (done) {
      words = 'Lamps ${lit.isEmpty ? 'none' : lit.join(', ')} alight, so the '
          'places add to ${play.weight}, which is ${play.over9} over nine. '
          '${play.inCode ? 'The message is in the code, and the reader gets it back whichever of the eight lamps goes out.' : 'The message is not in the code.'} '
          'One of ${play.level.ways} '
          '${play.level.ways == 1 ? 'message' : 'messages'} of the 256 that '
          '${play.level.ways == 1 ? 'lands' : 'land'} it; ${play.moves} '
          'lamp${play.moves == 1 ? '' : 's'} changed.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'No message in the code can fool the reader. Two different '
          'messages in the code would have to look the same with a lamp out '
          'for the reader to have a choice to make, and the sums forbid it. '
          'All 30 messages in the code were sent with each of their eight '
          'lamps put out before the sham was built, 240 readings, and the '
          'reader got every one of them back. This message, lamps '
          '${lit.isEmpty ? 'none' : lit.join(', ')} alight, adds to '
          '${play.weight}, which is ${play.over9} over nine, and '
          '${play.mended} of its eight lamps can go out and be put back.';
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
              done ? 'Sent.' : 'The reader is never fooled.',
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
