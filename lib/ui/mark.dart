import 'package:flutter/material.dart';

import '../game/clues.dart';
import '../game/grid.dart';
import '../game/line.dart';
import '../game/picture.dart';
import 'board_painter.dart';
import 'metrics.dart';
import 'palette.dart';

/// The mark: a T, drawn as a nonogram with its numbers beside it.
///
/// It is a real puzzle rather than a picture of one. The clues are read off it
/// the way every clue in this game is, and a test solves it from those clues
/// alone — so the mark on the icon is something a player could be handed. It
/// would be a poor advertisement for a game about solvable puzzles if its own
/// logo were not one.
class Mark extends StatelessWidget {
  const Mark({super.key, this.showClues = true, this.solved = true});

  /// The numbers beside it. Off below about a hundred points, where they are
  /// smaller than a pixel is worth and only muddy the letter.
  final bool showClues;

  /// Whether the T is filled in. The half solved version is for the title,
  /// where the game is being explained; the solved one is the logo.
  final bool solved;

  static final picture = Picture.of(const [
    '#######',
    '#######',
    '..###..',
    '..###..',
    '..###..',
    '..###..',
    '..###..',
  ]);

  static final clues = Clues.of(picture);

  /// The mark part way through: worked out down to [rows], and nothing below
  /// that touched.
  ///
  /// [crosses] is off for the logo. Crossing off where the picture is not is
  /// how a player works, and it is right on a board being played; on a mark it
  /// is forty two red crosses around a letter.
  static Grid worked({required int rows, bool crosses = true}) {
    var grid = Grid(width: picture.width, height: picture.height);
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < picture.width; col++) {
        if (!picture.at(row, col)) {
          if (crosses) grid = grid.mark(row, col, Square.blank);
          continue;
        }
        grid = grid.mark(row, col, Square.filled);
      }
    }
    return grid;
  }

  @override
  Widget build(BuildContext context) {
    final shown = showClues ? clues : _bare;
    return LayoutBuilder(
      builder: (context, box) => CustomPaint(
        size: Size(box.maxWidth, box.maxHeight),
        painter: BoardPainter(
          grid: solved
              ? worked(rows: picture.height, crosses: false)
              : worked(rows: 2),
          clues: shown,
          numbers: Theme.of(context).textTheme.bodyMedium!,
          metrics: Metrics(
            space: Size(box.maxWidth, box.maxHeight),
            clues: shown,
          ),
        ),
      ),
    );
  }

  static final _bare = Clues(
    rows: List.generate(picture.height, (_) => const <int>[]),
    columns: List.generate(picture.width, (_) => const <int>[]),
  );

  /// The mark on its paper, which is what an app icon is.
  static Widget icon() => const ColoredBox(
        color: Palette.paper,
        child: Padding(
          padding: EdgeInsets.all(58),
          child: Mark(showClues: false),
        ),
      );

  /// The mark on nothing, for an Android adaptive icon, where the background
  /// is a separate layer and the launcher may crop what is over it to a circle
  /// or a squircle or whatever this year's phone prefers.
  ///
  /// The padding is what keeps it out of the way of that crop: an adaptive
  /// icon shows about the middle two thirds, so the mark sits inside a little
  /// over half.
  static Widget iconForeground() => const Padding(
        padding: EdgeInsets.all(230),
        child: Mark(showClues: false),
      );
}
