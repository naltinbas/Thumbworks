import 'package:flutter/material.dart';

import '../yard/play.dart';
import 'palette.dart';

/// The card at the end of a yard.
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

  /// Askings used this yard.
  final int hints;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    final asked = hints == 0
        ? ', asking for nothing'
        : ', asking $hints time${hints == 1 ? '' : 's'}';
    if (play.isDone) {
      final task = play.yard.task;
      final did = task[0].toUpperCase() + task.substring(1);
      final par = play.yard.par!;
      if (play.flips <= par) {
        return '$did in ${play.flips} '
            'flip${play.flips == 1 ? '' : 's'}$asked, the fewest '
            'any flipping needs.';
      }
      return '$did in ${play.flips} flips$asked. A flipping of '
          '$par does it, if you want the yard again.';
    }
    return 'Eight flips and never two crowns, as the label said: a '
        'yard of four wears one or three, thirty-two ways each of '
        'the sixty-four, and a second king always drags a third '
        'out of its own peckers.';
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          decoration: BoxDecoration(
            color: Palette.panel,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
                color: play.isDone ? Palette.good : Palette.bad,
                width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: play.isDone
                    ? 'the crowning stands'
                    : 'never two crowns',
                child: ExcludeSemantics(
                  child: Text(
                    play.yard.name,
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
                  color: play.isDone ? Palette.good : Palette.bad,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              if (play.isDone && best) ...[
                const SizedBox(height: 3),
                const Text(
                  'Fewer flips than last time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                  const SizedBox(width: 9),
                  Expanded(child: _Button(label: 'Yards', onTap: onLeave)),
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
