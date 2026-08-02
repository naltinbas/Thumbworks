import 'package:flutter/material.dart';

import '../play/session.dart';
import 'palette.dart';

/// The line above the lanes: the score, the run, and what the last tap was.
class Ledger extends StatelessWidget {
  const Ledger({
    super.key,
    required this.session,
    required this.saying,
    required this.onLeave,
  });

  final Session session;

  /// The last judgement, while it is still worth showing.
  final Judgement? saying;

  final VoidCallback onLeave;

  static String wordFor(Judgement judgement) => switch (judgement) {
        Judgement.perfect => 'Perfect',
        Judgement.good => 'Good',
        Judgement.missed => 'Missed',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Leave the tune',
          ),
          Expanded(
            child: Center(
              // The word sits in the middle, where the eye already is, and
              // goes again quickly. A judgement that lingers is a judgement
              // still on screen when the next one arrives.
              child: saying == null
                  ? const SizedBox.shrink()
                  : Text(
                      wordFor(saying!),
                      style: TextStyle(
                        color: Palette.say(saying!),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.score}',
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              if (session.combo > 2)
                Text(
                  '${session.combo} in a row',
                  style: const TextStyle(
                    color: Palette.perfect,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
