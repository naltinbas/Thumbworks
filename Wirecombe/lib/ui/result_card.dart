import 'package:flutter/material.dart';

import '../wire/play.dart';
import 'palette.dart';

/// The card that ends a combe, either way.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.fewest,
    required this.isRecord,
    required this.onAgain,
    required this.onCombe,
  });

  final Play play;

  /// The standing record, after this run counted.
  final int? fewest;
  final bool isRecord;

  final VoidCallback onAgain;
  final VoidCallback onCombe;

  @override
  Widget build(BuildContext context) {
    final done = play.isDone;
    final words = done
        ? 'One run, every cottage joined, '
            '${play.lanesEnds.length} lane\'s '
            'end${play.lanesEnds.length == 1 ? '' : 's'} lit; '
            '${play.moves} wiring${play.moves == 1 ? '' : 's'} '
            'all told.'
            '${isRecord ? ' The fewest yet.' : fewest == null ? '' : ' Fewest yet: $fewest.'}'
        : 'Twelve wirings and always a window left lit. There '
            'always will be: four lines carry eight ends, every '
            'cottage on two wants ten, and the sweep found no '
            'run below two lane\'s ends.';
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
              done ? 'Wired.' : 'The ring never rounds.',
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
                  onPressed: onCombe,
                  child: const Text('The combe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
