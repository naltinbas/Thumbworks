import 'package:flutter/material.dart';

import '../score/play.dart';
import 'palette.dart';

/// The card at the end of a ring.
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

  /// Askings used this ring.
  final int hints;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    final asked = hints == 0
        ? ', asking for nothing'
        : ', asking $hints time${hints == 1 ? '' : 's'}';
    if (play.isDone) {
      return 'All ${play.ring.goods} good '
          'start${play.ring.goods == 1 ? '' : 's'} found in '
          '${play.tried.length} '
          'tr${play.tried.length == 1 ? 'y' : 'ies'}$asked: '
          'exactly as many as the ring runs ahead, as the ledger '
          'promised.';
    }
    return 'Every start of the ${play.ring.marks.length} tried, '
        'every walk grounded, as the label said: the ring runs '
        'nothing ahead, and the ledger gives a tied ring no good '
        'start at all.';
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
                    ? 'every good start is found'
                    : 'every start grounded',
                child: ExcludeSemantics(
                  child: Text(
                    play.ring.name,
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
                  'Fewer tries than last time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                  const SizedBox(width: 9),
                  Expanded(child: _Button(label: 'Rings', onTap: onLeave)),
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
