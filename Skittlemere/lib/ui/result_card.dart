import 'package:flutter/material.dart';

import '../alley/play.dart';
import 'palette.dart';

/// The card at the end of an alley, won or lost.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.won,
    required this.best,
    required this.hints,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Play play;
  final bool won;

  /// Whether this beat what was written down before.
  final bool best;

  /// Askings used this alley.
  final int hints;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    final asked = hints == 0
        ? ', asking for nothing'
        : ', asking $hints time${hints == 1 ? '' : 's'}';
    if (won) {
      return 'The last skittle was yours$asked: the count came to '
          'you at ${play.frame.count} and you never handed it back.';
    }
    return play.frame.winnable
        ? 'The house knocked last. The alley was yours at the start; '
            'somewhere a knock left the count off nought, and the '
            'house zeroed everything after.'
        : 'The house knocked last, as the label said it would: the '
            'count stood at nought before the first ball, and every '
            'knock of yours handed it one to zero.';
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          decoration: BoxDecoration(
            color: Palette.panel,
            borderRadius: BorderRadius.circular(13),
            border:
                Border.all(color: won ? Palette.good : Palette.bad, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: won ? 'the alley is yours' : 'the house has it',
                child: ExcludeSemantics(
                  child: Text(
                    play.frame.name,
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
              if (won && best) ...[
                const SizedBox(height: 3),
                const Text(
                  'Fewer askings than last time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                  const SizedBox(width: 9),
                  Expanded(child: _Button(label: 'Alleys', onTap: onLeave)),
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
                color: lit ? Palette.edge : Palette.alley,
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
