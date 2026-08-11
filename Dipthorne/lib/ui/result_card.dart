import 'package:flutter/material.dart';

import '../ring/play.dart';
import 'palette.dart';

/// The card under a dip that has ended, one way or the other.
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

  /// Askings used this dip.
  final int hints;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    if (play.won) {
      final asked = hints == 0
          ? ', and you asked for nothing'
          : ', asking $hints time${hints == 1 ? '' : 's'}';
      return 'Last in. Seat ${play.safe} is the one the rhyme cannot '
          'find$asked.';
    }
    return 'The rhyme found you, the ${_nth(play.out.length)} to go. The '
        'safe seat was ${play.safe}.';
  }

  static String _nth(int count) {
    if (count % 100 >= 11 && count % 100 <= 13) return '${count}th';
    switch (count % 10) {
      case 1:
        return '${count}st';
      case 2:
        return '${count}nd';
      case 3:
        return '${count}rd';
    }
    return '${count}th';
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          decoration: BoxDecoration(
            color: Palette.wall,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: play.won ? Palette.good : Palette.bad,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: play.won ? 'you are last in' : 'the rhyme found you',
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
                  color: play.won ? Palette.good : Palette.bad,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              if (best) ...[
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
                color: lit ? Palette.edge : Palette.dusk,
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
