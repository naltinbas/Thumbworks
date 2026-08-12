import 'package:flutter/material.dart';

import '../bead/play.dart';
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
      final repeats = play.strings - play.ring.asked;
      final clean = repeats == 0
          ? ', none of them a repeat'
          : ', $repeats of them repeat${repeats == 1 ? '' : 's'}';
      return 'All ${play.ring.asked} necklaces strung in '
          '${play.strings} string${play.strings == 1 ? '' : 's'}'
          '$clean$asked: the whole of what this ring can make.';
    }
    return 'The shelf holds all six, and the seventh was never '
        'there, as the label said: the four turns fix 16, 2, 4 and '
        '2 strings each, and twenty-four over four is six. String '
        'anything now and it is one of the six, turned.';
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
                    ? 'the shelf is full'
                    : 'the seventh was never there',
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
                  'Fewer strings than last time.',
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
