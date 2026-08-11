import 'package:flutter/material.dart';

import '../tower/play.dart';
import 'palette.dart';

/// The card under a tower raised home.
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

  /// Askings used this tower.
  final int hints;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    final moves = play.made;
    final fewest = play.spindle.fewest;
    final wager = play.spindle.wager;
    final asked = hints == 0
        ? ' and no asking'
        : ', asking $hints time${hints == 1 ? '' : 's'}';
    if (wager != null) {
      return 'Home in $moves$asked. The wager asked $wager, and the '
          'walk of every board says the floor is $fewest: the house '
          'was always safe, and now you have walked the proof.';
    }
    if (moves == fewest) {
      return 'Home in $moves$asked, and no play of any board does it '
          'in fewer.';
    }
    return 'Home in $moves$asked. The fewest is $fewest, if you want '
        'to go round again.';
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          decoration: BoxDecoration(
            color: Palette.panel,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Palette.good, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: 'the tower stands home',
                child: ExcludeSemantics(
                  child: Text(
                    play.spindle.name,
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
                style: const TextStyle(
                  color: Palette.good,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              if (best) ...[
                const SizedBox(height: 3),
                const Text(
                  'Fewer moves than last time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                  const SizedBox(width: 9),
                  Expanded(child: _Button(label: 'Towers', onTap: onLeave)),
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
                color: lit ? Palette.edge : Palette.bench,
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
