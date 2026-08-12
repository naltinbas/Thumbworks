import 'package:flutter/material.dart';

import '../show/play.dart';
import '../show/show.dart';
import 'palette.dart';

/// The card at the end of a bench.
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

  /// Askings used this bench.
  final int hints;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    final asked = hints == 0
        ? ', asking for nothing'
        : ', asking $hints time${hints == 1 ? '' : 's'}';
    if (play.show.sure) {
      if (play.benchWon) {
        return 'Every sitting of the ${play.played} landed the '
            'best$asked. Luck bowed today, and proves nothing: no '
            'rule makes it sure, and the fork stands.';
      }
      return '${play.played} sitting${play.played == 1 ? '' : 's'} '
          'and the last of them had you, as some sitting must: two '
          'openings can look alike with the best in different '
          'seats, so no rule of any kind lands it every time. '
          'Eleven of twenty-four is the ceiling.';
    }
    return 'The ${Show.asked} best marrows landed in ${play.played} '
        'sitting${play.played == 1 ? '' : 's'}$asked, against odds '
        'of ${play.show.wins} in ${play.show.of} a sitting.';
  }

  @override
  Widget build(BuildContext context) {
    final won = play.benchWon;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        decoration: BoxDecoration(
          color: Palette.panel,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
              color: won ? Palette.good : Palette.bad, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: won ? 'the bench is won' : 'the bench had you',
              child: ExcludeSemantics(
                child: Text(
                  play.show.name,
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
                color: won ? Palette.good : Palette.bad,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            if (won && play.show.winnable && best) ...[
              const SizedBox(height: 3),
              const Text(
                'Fewer sittings than last time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Palette.inkDim, fontSize: 12),
              ),
            ],
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 9),
                Expanded(child: _Button(label: 'Benches', onTap: onLeave)),
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
                color: lit ? Palette.edge : Palette.night,
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
