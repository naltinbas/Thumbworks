import 'package:flutter/material.dart';

import '../game/book.dart';
import '../game/clues.dart';
import '../game/grid.dart';
import '../game/line.dart';
import '../game/picture.dart';
import '../progress.dart';
import 'board_painter.dart';
import 'metrics.dart';
import 'palette.dart';

/// The way in.
///
/// One decision, which is Play, and it opens the first puzzle not yet solved.
/// Everything else here is there to say where the player is up to.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.progress, required this.onPlay});

  final Progress progress;
  final VoidCallback onPlay;

  /// The mark: a small nonogram, half worked out, with its numbers beside it.
  /// It is drawn by the same painter that draws the game, so it is the game.
  static final _mark = Picture.of(const [
    '.###.',
    '##.##',
    '#...#',
    '##.##',
    '.###.',
  ]);

  @override
  Widget build(BuildContext context) {
    final next = progress.next;
    final done = progress.count;

    return Scaffold(
      backgroundColor: Palette.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: BoardPainter(
                    grid: _halfWorked(),
                    clues: Clues.of(_mark),
                    // Read off the theme rather than the ambient
                    // DefaultTextStyle: a screen's build context sits above
                    // the Scaffold it returns, so the ambient style there is
                    // the bare one from before Material set it, with no font
                    // family in it at all.
                    numbers: Theme.of(context).textTheme.bodyMedium!,
                    metrics: Metrics(
                      space: const Size(150, 150),
                      clues: Clues.of(_mark),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Tallyloom',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The numbers say how many in a row.\nThe picture is what fits them all.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Palette.inkDim, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onPlay,
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.ink,
                    foregroundColor: Palette.paper,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    done == 0 ? 'Start' : 'Puzzle $next',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                done == 0
                    ? 'nothing solved yet'
                    : '$done solved · ${Book.chapterOf(next).title}',
                style: const TextStyle(color: Palette.inkDim, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The mark part way through, so it reads as a puzzle being solved rather
  /// than a picture that came with the app.
  static Grid _halfWorked() {
    var grid = Grid(width: _mark.width, height: _mark.height);
    for (var row = 0; row < _mark.height; row++) {
      for (var col = 0; col < _mark.width; col++) {
        if (row > 2) continue;
        grid = grid.mark(
          row,
          col,
          _mark.at(row, col) ? Square.filled : Square.blank,
        );
      }
    }
    return grid;
  }
}
