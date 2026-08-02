import 'package:flutter/material.dart';

import 'palette.dart';

/// How far, and how far before.
///
/// Small and out of the way at the top. A runner is read at speed, and a
/// scoreboard competing with the thing about to kill you is a scoreboard
/// nobody reads and an obstacle everybody hits.
class Ledger extends StatelessWidget {
  const Ledger({
    super.key,
    required this.tiles,
    required this.best,
    required this.onLeave,
  });

  final int tiles;
  final int best;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Leave the run',
          ),
          const Spacer(),
          if (best > 0) ...[
            Text(
              'best $best',
              style: const TextStyle(color: Palette.inkDim, fontSize: 14),
            ),
            const SizedBox(width: 14),
          ],
          Text(
            '$tiles',
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 26,
              fontWeight: FontWeight.w300,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
