import 'package:flutter/rendering.dart';

import '../game/clues.dart';
import '../game/grid.dart';
import '../game/line.dart';
import 'metrics.dart';
import 'palette.dart';

/// Draws the puzzle: the numbers, the squared paper, and what has been worked
/// out on it.
///
/// There is nothing to load. A nonogram is squares and two digit numbers, so
/// every pixel here is drawn, which means it is sharp at whatever size a phone
/// gives it and the app has no art in it at all.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.grid,
    required this.clues,
    required this.metrics,
    required this.numbers,
    this.finished = false,
  });

  final Grid grid;
  final Clues clues;
  final Metrics metrics;

  /// The face the clues are written in.
  ///
  /// Passed in rather than left to default, because a TextPainter inside a
  /// painter is outside the widget tree and so inherits nothing: no theme, no
  /// DefaultTextStyle, no font. Left to itself it picks whatever the platform
  /// hands it, which under a test is a placeholder that draws every glyph as a
  /// filled rectangle — and this board is nothing but two digit numbers.
  final TextStyle numbers;

  /// Once the picture is out, the crosses and the paper rules go and only the
  /// picture is left. It is the thing the player made, and it should be the
  /// thing they are looking at.
  final bool finished;

  static final _numbers = <String, TextPainter>{};

  @override
  void paint(Canvas canvas, Size size) {
    if (!finished) {
      _paintClues(canvas);
      _paintRules(canvas);
    }
    _paintSquares(canvas);
    if (!finished) _paintFrame(canvas);
  }

  void _paintSquares(Canvas canvas) {
    final drawn = Paint()..color = finished ? Palette.ink : Palette.drawn;
    final cross = Paint()
      ..color = Palette.crossed
      ..strokeWidth = (metrics.square * 0.08).clamp(1.2, 2.4)
      ..strokeCap = StrokeCap.round;

    for (var row = 0; row < grid.height; row++) {
      for (var col = 0; col < grid.width; col++) {
        final square = grid.at(row, col);
        if (square == Square.filled) {
          // Squares of a picture want to touch, so this is not inset. The
          // rounding is a hair, just enough to look drawn rather than printed.
          final at = metrics.squareAt(row, col);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              at.deflate(finished ? 0 : 0.5),
              Radius.circular(metrics.square * 0.12),
            ),
            drawn,
          );
        } else if (square == Square.blank && !finished) {
          final at = metrics.squareAt(row, col).deflate(metrics.square * 0.32);
          canvas.drawLine(at.topLeft, at.bottomRight, cross);
          canvas.drawLine(at.topRight, at.bottomLeft, cross);
        }
      }
    }
  }

  void _paintRules(Canvas canvas) {
    final thin = Paint()
      ..color = Palette.rule
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = Palette.ruleBold
      ..strokeWidth = 1.6;

    final board = metrics.grid;
    for (var col = 0; col <= clues.width; col++) {
      final x = board.left + col * metrics.square;
      canvas.drawLine(
        Offset(x, board.top),
        Offset(x, board.bottom),
        col % 5 == 0 ? thick : thin,
      );
    }
    for (var row = 0; row <= clues.height; row++) {
      final y = board.top + row * metrics.square;
      canvas.drawLine(
        Offset(board.left, y),
        Offset(board.right, y),
        row % 5 == 0 ? thick : thin,
      );
    }
  }

  void _paintFrame(Canvas canvas) {
    canvas.drawRect(
      metrics.grid,
      Paint()
        ..color = Palette.ruleBold
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintClues(Canvas canvas) {
    final size = metrics.clueSquare * 0.86;

    for (var row = 0; row < clues.height; row++) {
      final spent = _lineDone(grid.row(row), clues.rows[row]);
      for (var place = 0; place < clues.rows[row].length; place++) {
        _number(
          canvas,
          '${clues.rows[row][place]}',
          metrics.rowClueAt(row, place),
          size,
          spent,
        );
      }
    }
    for (var col = 0; col < clues.width; col++) {
      final spent = _lineDone(grid.column(col), clues.columns[col]);
      for (var place = 0; place < clues.columns[col].length; place++) {
        _number(
          canvas,
          '${clues.columns[col][place]}',
          metrics.columnClueAt(col, place),
          size,
          spent,
        );
      }
    }
  }

  /// Whether a clue has been satisfied by what is filled in its line.
  ///
  /// This is the only thing the game says back to the player, and it is
  /// deliberately not "that square is wrong". A clue going grey means the line
  /// now reads as its numbers say. It can be grey and still be wrong, if the
  /// right runs are in the wrong places, and finding that out is the puzzle.
  static bool _lineDone(List<Square> line, List<int> clue) => Clues.satisfied(
        clue,
        [for (final square in line) square == Square.filled],
      );

  void _number(Canvas canvas, String text, Rect box, double size, bool spent) {
    final key = '$text|${size.toStringAsFixed(1)}|$spent|${numbers.fontFamily}';
    final painter = _numbers.putIfAbsent(key, () {
      final made = TextPainter(
        text: TextSpan(
          text: text,
          style: numbers.copyWith(
            color: spent ? Palette.spent : Palette.ink,
            fontSize: size,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      made.layout();
      return made;
    });

    painter.paint(
      canvas,
      Offset(
        box.center.dx - painter.width / 2,
        box.center.dy - painter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(BoardPainter old) =>
      old.grid != grid ||
      old.metrics.square != metrics.square ||
      old.metrics.origin != metrics.origin ||
      old.numbers != numbers ||
      old.finished != finished;
}
