import 'package:flutter/material.dart';

import '../game/play.dart';
import '../game/review.dart';
import '../game/rules.dart';
import 'palette.dart';

/// What comes up when a game ends: who won, and how well you played.
///
/// Those are two different questions and this answers both, because in a game
/// of dice the first one is mostly not up to you and the second one entirely
/// is.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.review,
    required this.sharpest,
    required this.onAgain,
    required this.onLeave,
  });

  final Play play;
  final Review review;

  /// Whether that was the sharpest game yet.
  final bool sharpest;

  final VoidCallback onAgain;
  final VoidCallback onLeave;

  bool get won => play.won == Who.you;

  static String _move(Move move) => switch (move) {
        Move.bank => 'banked',
        Move.one => 'threw one',
        Move.two => 'threw two',
      };

  static String _instead(Move move) => switch (move) {
        Move.bank => 'banking',
        Move.one => 'one die',
        Move.two => 'two dice',
      };

  @override
  Widget build(BuildContext context) {
    final worst = review.worst;
    final perfect = review.mistakes == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: Palette.felt,
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
            won ? 'You won' : 'They won',
            style: TextStyle(
              color: won ? Palette.good : Palette.bad,
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${play.yours} to ${play.theirs}',
            style: const TextStyle(color: Palette.inkDim, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            perfect
                ? 'And you played it perfectly: every one of '
                    '${review.choices.length} decisions was the best there '
                    'was.${sharpest ? ' Your sharpest game yet.' : ''}'
                : '${review.choices.length - review.mistakes} of '
                    '${review.choices.length} decisions were the best there '
                    'was.${sharpest ? ' Your sharpest game yet.' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (worst.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final one in worst.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'On ${one.turn} at ${one.yours}–${one.theirs} you '
                  '${_move(one.took)}. ${_instead(one.best).substring(0, 1).toUpperCase()}'
                  '${_instead(one.best).substring(1)} was worth '
                  '${(one.cost * 100).toStringAsFixed(1)}% more.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Palette.inkDim,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),
          _Button(label: 'Another game', filled: true, onTap: onAgain),
          const SizedBox(height: 9),
          _Button(label: 'Leave the table', filled: false, onTap: onLeave),
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
                color: filled ? Palette.yours : Palette.night,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.yours : Palette.rail,
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
