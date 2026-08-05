import 'package:flutter/material.dart';

import '../stones/play.dart';
import '../stones/rounds.dart';
import 'palette.dart';

/// What comes up when the last stone goes.
///
/// Two things worth saying, and they are not the same thing: who won, and
/// whether the round was ever in doubt. Every round here starts winnable, so
/// losing one means a move was thrown away, and the card says which count.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.round,
    required this.play,
    required this.wrong,
    required this.clean,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Round round;
  final Play play;

  /// How many moves gave away a position that was winning.
  final int wrong;

  /// Whether this was the first time it has been won without one.
  final bool clean;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  bool get won => play.won == Who.you;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: Palette.moor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(
          color: won ? Palette.good : Palette.bad,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            won ? 'The last stone' : 'They took it',
            style: TextStyle(
              color: won ? Palette.good : Palette.bad,
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            won
                ? wrong == 0
                    ? 'And not one move given away.'
                        '${clean ? ' The first time on this round.' : ''}'
                    : 'You gave the round away $wrong '
                        '${wrong == 1 ? 'time' : 'times'} and they did not '
                        'take it. It will not always be so forgiving.'
                : wrong == 0
                    ? 'Which should not have happened — turn the numbers on '
                        'and see where it went.'
                    : 'You had it $wrong '
                        '${wrong == 1 ? 'time' : 'times'} and let it go. '
                        'Turn the numbers on and it is one subtraction.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          if (won)
            _Button(label: 'The next one', filled: true, onTap: onNext)
          else
            _Button(label: 'This one again', filled: true, onTap: onAgain),
          const SizedBox(height: 9),
          _Button(
            label: won ? 'This one again' : 'Back to the rounds',
            filled: false,
            onTap: won ? onAgain : onLeave,
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: GestureDetector(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: filled ? Palette.going : Palette.night,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.going : Palette.ledge,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: filled ? Palette.night : Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
