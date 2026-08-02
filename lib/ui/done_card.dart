import 'package:flutter/material.dart';

import '../game/clues.dart';
import '../game/grid.dart';
import '../game/maker.dart';
import '../game/line.dart';
import 'board_painter.dart';
import 'hud.dart';
import 'metrics.dart';
import 'palette.dart';

/// What comes up when the picture is out.
///
/// The picture is on it, drawn small and clean with no numbers beside it and
/// no crosses in it. It is the thing the player just made, and it has not been
/// seen without the working on top of it until now.
class DoneCard extends StatelessWidget {
  const DoneCard({
    super.key,
    required this.number,
    required this.puzzle,
    required this.took,
    required this.best,
    required this.beat,
    required this.reveal,
    required this.onNext,
    required this.onBook,
  });

  final int number;
  final Puzzle puzzle;
  final Duration took;

  /// The best time for this puzzle, which is [took] itself the first time.
  final Duration best;

  /// Whether this go beat a time that was already there.
  final bool beat;

  final Animation<double> reveal;
  final VoidCallback onNext;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: reveal,
      child: ColoredBox(
        color: Palette.veil,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Puzzle $number',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 15),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Solved',
                  style: TextStyle(
                    color: Palette.good,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 24),

                // The picture on its own, drawn small and clean.
                SizedBox(
                  width: 168,
                  height: 168,
                  child: CustomPaint(
                    painter: BoardPainter(
                      grid: Grid(
                        width: puzzle.width,
                        height: puzzle.height,
                        squares: [
                          for (var row = 0; row < puzzle.height; row++)
                            for (var col = 0; col < puzzle.width; col++)
                              puzzle.picture.at(row, col)
                                  ? Square.filled
                                  : Square.blank,
                        ],
                      ),
                      clues: puzzle.clues,
                      numbers: Theme.of(context).textTheme.bodyMedium!,
                      metrics: Metrics(
                        space: const Size(168, 168),
                        clues: _bare(puzzle),
                      ),
                      finished: true,
                    ),
                  ),
                ),

                const SizedBox(height: 26),
                Text(
                  PuzzleBar.face(took),
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 30,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  beat
                      ? 'your best yet'
                      : best < took
                          ? 'best ${PuzzleBar.face(best)}'
                          : 'first time through',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),

                const SizedBox(height: 34),
                _Button(label: 'Next puzzle', filled: true, onTap: onNext),
                const SizedBox(height: 10),
                _Button(label: 'Back to the book', filled: false, onTap: onBook),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The same grid with nothing written in the margins.
  ///
  /// The clue strips are sized from how deep the deepest clue is, so a set of
  /// empty clues is a picture with the whole space to itself. The numbers have
  /// done their job by now and the picture has not.
  static Clues _bare(Puzzle puzzle) => Clues(
        rows: List.generate(puzzle.height, (_) => const <int>[]),
        columns: List.generate(puzzle.width, (_) => const <int>[]),
      );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.filled, required this.onTap});

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: filled ? Palette.good : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: filled ? Palette.good : Palette.rule, width: 1.4),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: filled ? Palette.paper : Palette.ink,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
