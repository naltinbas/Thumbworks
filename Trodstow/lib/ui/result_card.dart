import 'package:flutter/material.dart';

import '../link/parishes.dart';
import '../link/play.dart';
import 'palette.dart';

/// The card under a parish that is joined up.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.round,
    required this.play,
    required this.best,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Round round;
  final Play play;

  /// Whether this beat what was written down before.
  final bool best;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    if (play.isCheapest) {
      return 'Every hamlet joined up, on ${play.yards} yards of path, and '
          'there is no way to do it on fewer.';
    }
    return 'Every hamlet joined up, on ${play.yards} yards of path. It can be '
        'done on ${round.yards}.';
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          decoration: BoxDecoration(
            color: Palette.verge,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: play.isCheapest ? Palette.good : Palette.edge,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: 'the parish is joined up',
                child: ExcludeSemantics(
                  child: Text(
                    round.name,
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
                  color: play.isCheapest ? Palette.good : Palette.inkDim,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              if (best) ...[
                const SizedBox(height: 3),
                const Text(
                  'Fewer than last time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                  const SizedBox(width: 9),
                  Expanded(child: _Button(label: 'Parishes', onTap: onLeave)),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
