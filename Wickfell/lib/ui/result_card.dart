import 'package:flutter/material.dart';

import '../lamps/levels.dart';
import '../lamps/play.dart';
import 'palette.dart';

/// What comes up when the last lamp goes out.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.level,
    required this.play,
    required this.best,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Level level;
  final Play play;

  /// Whether that was the fewest presses this board has been put out in.
  final bool best;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  bool get perfect => play.pressed == level.presses;

  @override
  Widget build(BuildContext context) {
    final over = play.pressed - level.presses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: Palette.hill,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: Palette.good, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            perfect ? 'Not a press wasted' : 'All out',
            style: const TextStyle(
              color: Palette.good,
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            perfect
                ? '${play.pressed} presses, which is the fewest there are.'
                    '${best ? ' Your best yet.' : ''}'
                : '${play.pressed} presses. It can be done in '
                    '${level.presses} — $over more than it had to be.'
                    '${best ? ' Still your best yet.' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _Button(label: 'The next one', filled: true, onTap: onNext),
          const SizedBox(height: 9),
          _Button(
            label: perfect ? 'Back to the boards' : 'This one again',
            filled: false,
            onTap: perfect ? onLeave : onAgain,
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
                color: filled ? Palette.lit : Palette.night,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.lit : Palette.socket,
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
