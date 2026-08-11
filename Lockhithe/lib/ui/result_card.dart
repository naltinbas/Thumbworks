import 'package:flutter/material.dart';

import '../quay/odds.dart';
import '../quay/play.dart';
import 'palette.dart';

/// The card under a settled round.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.best,
    required this.hints,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Play play;

  /// Whether this beat what was written down before.
  final bool best;

  /// Askings used this round.
  final int hints;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    final odds = Odds.byCounting(play.berth.lockers, play.berth.looks);
    final said = '${odds.$1} in ${odds.$2}';
    if (play.found && play.through) {
      return 'Every sailor came through: no loop outran the looks. '
          'Following the chits, that happens $said, round after round.';
    }
    if (!play.found) {
      return 'Your looks ran out. The crew fails as one, and following '
          'the chits from your own locker is the only walk that fails '
          'only when it must.';
    }
    return 'You came through, and sailor ${play.sunkBy + 1} did not: '
        'their loop outran the looks, and the crew fails as one. The '
        'loops were set before the first door opened.';
  }

  @override
  Widget build(BuildContext context) {
    final through = play.found && play.through;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        decoration: BoxDecoration(
          color: Palette.wharf,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: through ? Palette.good : Palette.bad,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: through ? 'the crew is through' : 'the crew is sunk',
              child: ExcludeSemantics(
                child: Text(
                  play.berth.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _line,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: through ? Palette.good : Palette.bad,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            if (best) ...[
              const SizedBox(height: 3),
              const Text(
                'Cleaner than last time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Palette.inkDim, fontSize: 12),
              ),
            ],
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 9),
                Expanded(child: _Button(label: 'Berths', onTap: onLeave)),
                const SizedBox(width: 9),
                Expanded(
                  child: _Button(label: 'Next', onTap: onNext, lit: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap, this.lit = false});

  final String label;
  final VoidCallback onTap;
  final bool lit;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: lit ? Palette.edge : Palette.quay,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
