import 'package:flutter/material.dart';

import '../game/play.dart';
import '../game/plots.dart';
import 'hud.dart';
import 'palette.dart';

/// What comes up when a board ends.
///
/// A panel across the bottom, and the board keeps the rest of the screen. At
/// the end of a lost board the thing worth looking at is where the mines
/// actually were, and a card over the top of it hides exactly that.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.plot,
    required this.play,
    required this.seconds,
    required this.asked,
    required this.best,
    required this.onAgain,
    required this.onLeave,
  });

  final Plot plot;
  final Play play;
  final int seconds;

  /// How many times the player asked why.
  final int asked;

  /// Whether this was the quickest clear of this plot yet.
  final bool best;

  final VoidCallback onAgain;
  final VoidCallback onLeave;

  bool get cleared => play.ending == Ending.cleared;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Palette.plot,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(
          color: cleared ? Palette.proved : Palette.mine,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cleared ? 'Cleared' : 'Gone up',
            style: TextStyle(
              color: cleared ? Palette.proved : Palette.mine,
              fontSize: 32,
              fontWeight: FontWeight.w300,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cleared
                ? '${Ledger.clock(seconds)}'
                    '${best ? ' — your quickest' : ''}'
                    '${asked == 0 ? '' : ', $asked ${asked == 1 ? 'answer' : 'answers'} asked for'}'
                : 'That one was there to be worked out. Every square on this '
                    'board could be settled without a guess.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cleared ? Palette.ink : Palette.inkDim,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          _Button(label: 'Another one', filled: true, onTap: onAgain),
          const SizedBox(height: 9),
          _Button(label: 'Back to the plots', filled: false, onTap: onLeave),
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
                color: filled ? Palette.ember : Palette.night,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.ember : Palette.furrow,
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
