import 'dart:math';

import 'package:flutter/rendering.dart';

import '../game/board.dart';
import 'palette.dart';

/// Where the squares are.
///
/// One object works it out and the painter, the finger and the tests all ask
/// it. Working it out twice is how a man appears to be picked up from a square
/// the thumb was not on.
class Metrics {
  factory Metrics(Size space) {
    final side = min(space.width, space.height);
    final square = side / Board.size;
    return Metrics._(
      square: square,
      origin: Offset(
        (space.width - side) / 2,
        (space.height - side) / 2,
      ),
    );
  }

  const Metrics._({required this.square, required this.origin});

  final double square;
  final Offset origin;

  Rect squareAt(Square at) => Rect.fromLTWH(
        origin.dx + at.col * square,
        origin.dy + at.row * square,
        square,
        square,
      );

  Rect get board => Rect.fromLTWH(
        origin.dx,
        origin.dy,
        square * Board.size,
        square * Board.size,
      );

  /// The square under a point, or null if the point is off the board.
  Square? under(Offset at) {
    final x = at.dx - origin.dx;
    final y = at.dy - origin.dy;
    if (x < 0 || y < 0) return null;
    if (x >= square * Board.size || y >= square * Board.size) return null;
    return Square(y ~/ square, x ~/ square);
  }
}

/// Draws the board and the men on it.
///
/// Nothing to load: the men are three circles in three colours and the board
/// is lines, so it is sharp at any size and the app ships no art at all.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.metrics,
    this.picked,
    this.canGo = const [],
    this.last,
    this.dimmed = false,
  });

  final Board board;
  final Metrics metrics;

  /// The man the player has picked up.
  final Square? picked;

  /// Where he could put him down.
  final List<Square> canGo;

  /// The move the other side just played.
  final Move? last;

  /// Faded, for the board behind the card at the end.
  final bool dimmed;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBoard(canvas);
    _paintMarks(canvas);
    _paintMen(canvas);
  }

  void _paintBoard(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(metrics.board, const Radius.circular(6)),
      Paint()..color = Palette.board,
    );

    // The corners and the throne are not ordinary squares — only the king may
    // stand on them, and they help take a man pinned against them — so they
    // are marked. A player who has to be told that in words will be told it
    // twice and remember it neither time.
    final inlay = Paint()..color = Palette.inlay;
    for (final at in [...Board.corners, Board.throne]) {
      final box = metrics.squareAt(at).deflate(metrics.square * 0.3);
      canvas.drawPath(
        Path()
          ..moveTo(box.center.dx, box.top)
          ..lineTo(box.right, box.center.dy)
          ..lineTo(box.center.dx, box.bottom)
          ..lineTo(box.left, box.center.dy)
          ..close(),
        inlay,
      );
    }

    final rule = Paint()
      ..color = Palette.rule
      ..strokeWidth = 1;
    for (var i = 1; i < Board.size; i++) {
      final x = metrics.origin.dx + i * metrics.square;
      final y = metrics.origin.dy + i * metrics.square;
      canvas.drawLine(
        Offset(x, metrics.board.top),
        Offset(x, metrics.board.bottom),
        rule,
      );
      canvas.drawLine(
        Offset(metrics.board.left, y),
        Offset(metrics.board.right, y),
        rule,
      );
    }
  }

  void _paintMarks(Canvas canvas) {
    if (last != null) {
      final tint = Paint()..color = Palette.last;
      for (final at in [last!.from, last!.to]) {
        canvas.drawRect(metrics.squareAt(at), tint);
      }
    }
    if (picked != null) {
      canvas.drawRect(
        metrics.squareAt(picked!),
        Paint()..color = Palette.picked,
      );
    }
    // Where he could go, as a dot rather than a wash, so a board with fourteen
    // squares lit does not turn into a light show.
    final dot = Paint()..color = Palette.open.withValues(alpha: 0.85);
    for (final at in canGo) {
      canvas.drawCircle(
        metrics.squareAt(at).center,
        metrics.square * 0.11,
        dot,
      );
    }
  }

  void _paintMen(Canvas canvas) {
    final fade = dimmed ? 0.35 : 1.0;
    for (final at in board.occupied) {
      final piece = board.at(at)!;
      final box = metrics.squareAt(at);
      final radius = metrics.square * (piece == Piece.raider ? 0.31 : 0.34);
      final colour = switch (piece) {
        Piece.raider => Palette.raider,
        Piece.guard => Palette.guard,
        Piece.king => Palette.king,
      };

      canvas.drawCircle(
        box.center.translate(0, metrics.square * 0.03),
        radius,
        Paint()..color = Palette.night.withValues(alpha: 0.4 * fade),
      );
      canvas.drawCircle(
        box.center,
        radius,
        Paint()..color = colour.withValues(alpha: fade),
      );

      // The king wears a ring, because on a small screen gold and bone are
      // one colour to anybody in a hurry.
      if (piece == Piece.king) {
        canvas.drawCircle(
          box.center,
          radius * 0.52,
          Paint()
            ..color = Palette.board.withValues(alpha: fade)
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.square * 0.055,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter old) =>
      old.board != board ||
      old.picked != picked ||
      old.last != last ||
      old.dimmed != dimmed ||
      old.canGo.length != canGo.length ||
      old.metrics.square != metrics.square ||
      old.metrics.origin != metrics.origin;
}
