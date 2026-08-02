import 'dart:math';

import 'package:flutter/rendering.dart';

import '../game/clues.dart';

/// Where everything is.
///
/// One object works this out, and the painter, the finger and the tests all
/// ask it. Working it out twice is how a square lights up somewhere the thumb
/// is not, and on a grid of a hundred squares that is a bug nobody can see and
/// everybody can feel.
class Metrics {
  factory Metrics({required Size space, required Clues clues}) {
    // The clue strips are narrower than the squares they belong to. A clue is
    // one or two digits and a square is a thumb, so giving them the same width
    // would spend a third of a small screen on numbers.
    const clueShare = 0.62;

    final across = clues.width + clues.deepestRow * clueShare;
    final down = clues.height + clues.deepestColumn * clueShare;

    final square = min(space.width / across, space.height / down);
    final gutterLeft = clues.deepestRow * clueShare * square;
    final gutterTop = clues.deepestColumn * clueShare * square;

    final board = Size(
      gutterLeft + clues.width * square,
      gutterTop + clues.height * square,
    );

    return Metrics._(
      clues: clues,
      square: square,
      clueSquare: square * clueShare,
      origin: Offset(
        (space.width - board.width) / 2 + gutterLeft,
        (space.height - board.height) / 2 + gutterTop,
      ),
    );
  }

  const Metrics._({
    required this.clues,
    required this.square,
    required this.clueSquare,
    required this.origin,
  });

  final Clues clues;

  /// The side of one square of the picture.
  final double square;

  /// The side of one clue's slot, which is smaller.
  final double clueSquare;

  /// The top left corner of the grid itself, past the clue strips.
  final Offset origin;

  Rect squareAt(int row, int col) => Rect.fromLTWH(
        origin.dx + col * square,
        origin.dy + row * square,
        square,
        square,
      );

  Rect get grid => Rect.fromLTWH(
        origin.dx,
        origin.dy,
        clues.width * square,
        clues.height * square,
      );

  /// Where a clue goes. Row clues run right up to the grid and column clues
  /// run down to it, so the last number of each is the one next to its line,
  /// which is the one being read.
  Rect rowClueAt(int row, int place) => Rect.fromLTWH(
        origin.dx - (clues.rows[row].length - place) * clueSquare,
        origin.dy + row * square,
        clueSquare,
        square,
      );

  Rect columnClueAt(int col, int place) => Rect.fromLTWH(
        origin.dx + col * square,
        origin.dy - (clues.columns[col].length - place) * clueSquare,
        square,
        clueSquare,
      );

  /// The square under a point, or null if the point is not on the grid.
  ///
  /// A little forgiveness round the edge, because a thumb aiming at the last
  /// column lands half on it and half on the margin, and a stroke that stops
  /// dead at the edge of the grid feels broken rather than careful.
  ({int row, int col})? squareUnder(Offset at, {double slack = 0}) {
    final x = at.dx - origin.dx;
    final y = at.dy - origin.dy;
    if (x < -slack || y < -slack) return null;
    if (x > clues.width * square + slack) return null;
    if (y > clues.height * square + slack) return null;

    final col = (x ~/ square).clamp(0, clues.width - 1);
    final row = (y ~/ square).clamp(0, clues.height - 1);
    return (row: row, col: col);
  }
}
