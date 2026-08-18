import 'package:flutter/material.dart';

import '../paling/play.dart';
import 'palette.dart';

/// The card that ends an ask, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onFence,
  });

  final Play play;

  /// The standing record, after this fence counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onFence;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final level = play.level;
    final String words;
    if (done) {
      words = 'The fence stands ${play.fence.join(', ')}, longest climb '
          '${play.climb} and longest drop ${play.drop}. One of '
          '${_commas(level.ways)} '
          '${level.ways == 1 ? 'fence' : 'fences'} of the 3,628,800 that '
          '${level.ways == 1 ? 'does' : 'do'} it. '
          '${play.moves} move${play.moves == 1 ? '' : 's'}.'
          '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}';
    } else {
      words = 'Read the tags. Each paling carries the longest climb ending '
          'there and the longest drop ending there, and no two palings on a '
          'fence can carry the same tag: of any two, the taller one either '
          'stands to the right, which makes its climb longer, or to the '
          'left, which makes the other one\'s drop longer. Tags with both '
          'numbers under four come to nine, three by three. There are ten '
          'palings. So one of them carries a four whatever you do, which is '
          'to say the fence holds a climb of four or a drop of four. Nine '
          'palings can dodge it, in 1,764 ways. Ten cannot, and the sweep '
          'agrees on all 3,628,800.';
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
              done ? 'Fenced.' : 'Nine tags, ten palings.',
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
                  onPressed: onFence,
                  child: const Text('The fence line'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _commas(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
