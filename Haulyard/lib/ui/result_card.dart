import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/yard.dart';
import 'palette.dart';

/// What comes up when a yard is finished.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.level,
    required this.yard,
    required this.best,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Level level;
  final Yard yard;

  /// Whether that was the fewest shoves this yard has been finished in.
  final bool best;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  bool get perfect => yard.pushes == level.par;

  @override
  Widget build(BuildContext context) {
    final over = yard.pushes - level.par;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Palette.shed,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: Palette.good, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            perfect ? 'Nothing wasted' : 'Yard cleared',
            style: const TextStyle(
              color: Palette.good,
              fontSize: 30,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            perfect
                ? '${yard.pushes} shoves, which is the fewest there are.'
                : '${yard.pushes} shoves. It can be done in ${level.par}, '
                    '$over more than it had to be.'
                    '${best ? ' Your best yet.' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          _Button(label: 'The next one', filled: true, onTap: onNext),
          const SizedBox(height: 9),
          _Button(
            label: perfect ? 'Back to the yards' : 'This one again',
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
          height: 50,
          child: GestureDetector(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: filled ? Palette.good : Palette.night,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.good : Palette.wall,
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
