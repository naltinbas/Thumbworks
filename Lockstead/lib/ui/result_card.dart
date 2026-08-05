import 'package:flutter/material.dart';

import '../lock/boards.dart';
import '../lock/play.dart';
import 'palette.dart';
import 'peg.dart';

/// What comes up when a lock is opened, or when the guesses run out.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.board,
    required this.play,
    required this.best,
    required this.onAgain,
    required this.onLeave,
  });

  final Board board;
  final Play play;

  /// Whether that was the fewest guesses this lock has been opened in.
  final bool best;

  final VoidCallback onAgain;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final open = play.isOpen;
    final took = play.tries.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: Palette.bench,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(
          color: open ? Palette.good : Palette.bad,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            open ? 'Open' : 'Still shut',
            style: TextStyle(
              color: open ? Palette.good : Palette.bad,
              fontSize: 30,
              fontWeight: FontWeight.w300,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 10),
          if (!open) ...[
            const Text(
              'It was',
              style: TextStyle(color: Palette.inkDim, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final colour in play.lock.pegsOf(play.secret)) ...[
                  Peg(colour: colour, side: 34),
                  const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(
            open
                ? took == 1
                    ? 'First guess. That is luck rather than skill, and it '
                        'counts all the same.'
                    : 'In $took guesses.'
                        '${took < board.inside ? ' The lock is only good for ${board.inside}, and you did not need them.' : ''}'
                        '${best ? ' Your fewest yet.' : ''}'
                : 'The lock always opens in ${board.inside}. This one could '
                    'have been worked out. Press Show me next time and it '
                    'will tell you which guess leaves the least behind.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _Button(label: 'Another lock', filled: true, onTap: onAgain),
          const SizedBox(height: 9),
          _Button(label: 'Back to the locks', filled: false, onTap: onLeave),
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
                color: filled ? Palette.brass : Palette.night,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.brass : Palette.groove,
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
