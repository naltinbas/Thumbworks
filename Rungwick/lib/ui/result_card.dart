import 'package:flutter/material.dart';

import '../ladder/climbs.dart';
import '../ladder/play.dart';
import 'palette.dart';

/// What comes up when a climb is finished.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.climb,
    required this.play,
    required this.best,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Climb climb;
  final Play play;

  /// Whether that was the fewest rungs this climb has been done in.
  final bool best;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  bool get perfect => play.taken == climb.rungs;

  @override
  Widget build(BuildContext context) {
    final over = play.taken - climb.rungs;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: Palette.board,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: Palette.good, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            perfect ? 'Not a rung wasted' : 'Up',
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
                ? '${play.taken} rungs, which is the fewest there are.'
                    '${best ? ' Your best yet.' : ''}'
                : '${play.taken} rungs. It can be done in ${climb.rungs}, '
                    '$over more than it had to be.'
                    '${best ? ' Still your best yet.' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            play.words.join(' · '),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.inkDim,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _Button(label: 'The next one', filled: true, onTap: onNext),
          const SizedBox(height: 9),
          _Button(
            label: perfect ? 'Back to the climbs' : 'This one again',
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
                color: filled ? Palette.rope : Palette.night,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.rope : Palette.rungEdge,
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
