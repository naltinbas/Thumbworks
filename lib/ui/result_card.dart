import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/game.dart';
import 'palette.dart';

/// What comes up when the game ends.
///
/// The board stays behind it, faded, because the position at the end is the
/// thing worth looking at: it says how the game was won, which is what a
/// player learns from.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.game,
    required this.playing,
    required this.reveal,
    required this.onAgain,
    required this.onTitle,
  });

  final Game game;
  final Side playing;
  final Animation<double> reveal;
  final VoidCallback onAgain;
  final VoidCallback onTitle;

  /// The headline: what happened, in the fewest words that are true.
  String get _what => switch (game.drawn) {
        Drawn.repeated => 'Round and round',
        Drawn.stale => 'Nothing doing',
        Drawn.no => switch (game.board.outcome) {
            Outcome.kingAway => 'The king is away',
            Outcome.kingTaken => 'The king is taken',
            Outcome.shutIn => 'Nowhere to go',
            Outcome.none => '',
          },
      };

  /// And what it means for the player.
  String get _andSo {
    final winner = game.winner;
    if (winner == null) {
      return game.drawn == Drawn.repeated
          ? 'The same position three times over. A draw.'
          : 'Fifty moves with nothing taken. A draw.';
    }
    return winner == playing ? 'You win.' : 'You lose.';
  }

  @override
  Widget build(BuildContext context) {
    final winner = game.winner;
    final tint = winner == null
        ? Palette.inkDim
        : winner == playing
            ? Palette.good
            : Palette.raider;

    return FadeTransition(
      opacity: reveal,
      child: ColoredBox(
        color: Palette.veil.withValues(alpha: 0.88),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _what,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tint,
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _andSo,
                  style: const TextStyle(color: Palette.ink, fontSize: 17),
                ),
                const SizedBox(height: 6),
                Text(
                  '${game.played} moves',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
                const SizedBox(height: 32),
                _Button(label: 'Play again', filled: true, onTap: onAgain),
                const SizedBox(height: 10),
                _Button(label: 'Back to the start', filled: false, onTap: onTitle),
              ],
            ),
          ),
        ),
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
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: GestureDetector(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: filled ? Palette.good : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: filled ? Palette.good : Palette.rule,
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
      );
}
