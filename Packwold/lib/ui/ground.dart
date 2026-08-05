import 'package:flutter/material.dart';

import '../fit/pieces.dart';
import '../fit/play.dart';
import 'palette.dart';

/// Where everything on the box is.
///
/// The painter and the finger both use this, which is the point of it: a
/// square is where it is drawn, and there is no second sum that could
/// disagree with the first.
class Metrics {
  Metrics(this.box, Size room) {
    final across = (room.width - _margin * 2) / box.wide;
    final down = (room.height - _margin * 2) / box.deep;
    cell = across < down ? across : down;
    corner = Offset(
      (room.width - cell * box.wide) / 2,
      (room.height - cell * box.deep) / 2,
    );
  }

  static const _margin = 4.0;

  final Box box;

  late final double cell;
  late final Offset corner;

  Rect squareAt(int row, int column) => Rect.fromLTWH(
        corner.dx + column * cell,
        corner.dy + row * cell,
        cell,
        cell,
      );

  /// The square under a point, as a row and a column, or null off the box.
  (int, int)? whereIs(Offset touch) {
    final column = ((touch.dx - corner.dx) / cell).floor();
    final row = ((touch.dy - corner.dy) / cell).floor();
    if (row < 0 || row >= box.deep || column < 0 || column >= box.wide) {
      return null;
    }
    return (row, column);
  }
}

/// Paints one shape's squares into a rectangle of cells, with the letter on
/// it. Used for the box, the tray and the logo, so a piece looks the same
/// everywhere it is drawn.
void paintShape(
  Canvas canvas,
  Shape shape,
  int piece,
  Offset corner,
  double cell, {
  double alpha = 1,
  bool outlineOnly = false,
}) {
  final colour = Palette.paintFor(piece).withValues(alpha: alpha);
  final round = Radius.circular(cell * 0.16);

  for (final (row, column) in shape.cells) {
    final square = Rect.fromLTWH(
      corner.dx + column * cell,
      corner.dy + row * cell,
      cell,
      cell,
    ).deflate(cell * 0.045);

    canvas.drawRRect(
      RRect.fromRectAndRadius(square, round),
      Paint()
        ..color = colour
        ..style = outlineOnly ? PaintingStyle.stroke : PaintingStyle.fill
        ..strokeWidth = cell * 0.09,
    );
  }
  if (outlineOnly) return;

  // The letter, on the piece's middle square if it has one and its first
  // otherwise, so it never lands on a gap in the shape.
  final middle = shape.cells[shape.cells.length ~/ 2];
  final painter = TextPainter(
    text: TextSpan(
      text: shape.letter,
      style: TextStyle(
        color: Palette.night.withValues(alpha: alpha * 0.72),
        // Named rather than left to the default, because a painter has no
        // theme to ask and the rest of the game is set in this one.
        fontFamily: 'Roboto',
        fontSize: cell * 0.5,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    corner +
        Offset(
          (middle.$2 + 0.5) * cell - painter.width / 2,
          (middle.$1 + 0.5) * cell - painter.height / 2,
        ),
  );
}

/// The box: the ground to cover, the holes in it, and the pieces lying on it.
class Ground extends CustomPainter {
  const Ground({
    required this.play,
    required this.holding,
    required this.pointing,
    required this.wrong,
  });

  final Play play;

  /// The piece in hand, or -1.
  final int holding;

  /// Squares the game is pointing at.
  final List<int> pointing;

  /// Whether it is pointing at something to pick up rather than put down.
  final bool wrong;

  @override
  void paint(Canvas canvas, Size size) {
    final box = play.box;
    final metrics = Metrics(box, size);
    final cell = metrics.cell;

    for (var row = 0; row < box.deep; row++) {
      for (var column = 0; column < box.wide; column++) {
        if (box.isHole(row, column)) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            metrics.squareAt(row, column).deflate(cell * 0.03),
            Radius.circular(cell * 0.1),
          ),
          Paint()..color = Palette.chalk,
        );
      }
    }

    for (var piece = 0; piece < play.pieces; piece++) {
      final laid = play.placed(piece);
      if (laid == null) continue;
      paintShape(
        canvas,
        laid.shape,
        Piece.numberOf(laid.letter),
        metrics.corner +
            Offset(laid.column * cell, laid.row * cell),
        cell,
        alpha: holding == piece ? 0.55 : 1,
      );
    }

    if (pointing.isEmpty) return;
    final ring = Paint()
      ..color = wrong ? Palette.bad : Palette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.07;
    for (var row = 0; row < box.deep; row++) {
      for (var column = 0; column < box.wide; column++) {
        if (!pointing.contains(box.at(row, column))) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            metrics.squareAt(row, column).deflate(cell * 0.1),
            Radius.circular(cell * 0.12),
          ),
          ring,
        );
      }
    }
  }

  @override
  bool shouldRepaint(Ground old) =>
      old.play != play ||
      old.holding != holding ||
      old.wrong != wrong ||
      old.pointing.length != pointing.length ||
      !old.pointing.every(pointing.contains);
}

/// One piece in the tray, drawn the way it is being held.
class Held extends CustomPainter {
  const Held({required this.shape, required this.piece, required this.faded});

  final Shape shape;
  final int piece;
  final bool faded;

  @override
  void paint(Canvas canvas, Size size) {
    final across = size.width / shape.wide;
    final down = size.height / shape.deep;
    final cell = across < down ? across : down;

    paintShape(
      canvas,
      shape,
      piece,
      Offset(
        (size.width - cell * shape.wide) / 2,
        (size.height - cell * shape.deep) / 2,
      ),
      cell,
      alpha: faded ? 0.4 : 1,
    );
  }

  @override
  bool shouldRepaint(Held old) =>
      old.shape.picture != shape.picture ||
      old.piece != piece ||
      old.faded != faded;
}
