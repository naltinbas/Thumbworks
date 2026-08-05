import 'package:flutter/material.dart';

import '../board/play.dart';
import '../board/puzzles.dart';
import 'palette.dart';

/// What comes up when one piece is left standing.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.puzzle,
    required this.play,
    required this.clean,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Puzzle puzzle;
  final Play play;

  /// Whether it was finished without taking anything back or being shown.
  final bool clean;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'One left',
            style: TextStyle(
              color: Palette.good,
              fontSize: 30,
              fontWeight: FontWeight.w300,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            clean
                ? 'In ${puzzle.takes} captures, first time through. There was '
                    'only ever one way to do it.'
                : 'In ${puzzle.takes} captures. There was only ever one way '
                    'to do it — worth another go without the help.',
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
            label: clean ? 'Back to the puzzles' : 'This one again',
            filled: false,
            onTap: clean ? onLeave : onAgain,
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
                color: filled ? Palette.picked : Palette.night,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.picked : Palette.light,
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
