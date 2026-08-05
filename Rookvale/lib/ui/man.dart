import 'package:flutter/material.dart';

import '../board/pieces.dart';
import 'palette.dart';

/// One piece, drawn as a shape rather than a letter.
///
/// Six shapes that are different at a glance and at a quarter of an inch, and
/// different without relying on colour: every piece here is the same colour,
/// because they are all yours, so shape is the only thing telling them apart.
class Man extends StatelessWidget {
  const Man({
    super.key,
    required this.piece,
    this.side = 44,
    this.picked = false,
  });

  final Piece piece;
  final double side;

  /// Whether this is the piece about to take.
  final bool picked;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: side,
        height: side,
        child: CustomPaint(painter: _ManPainter(piece: piece, picked: picked)),
      );
}

class _ManPainter extends CustomPainter {
  const _ManPainter({required this.piece, required this.picked});

  final Piece piece;
  final bool picked;

  @override
  void paint(Canvas canvas, Size size) {
    final middle = Offset(size.width / 2, size.height / 2);
    final reach = size.shortestSide * 0.5;
    final fill = Paint()..color = picked ? Palette.picked : Palette.piece;
    final line = Paint()
      ..color = picked ? Palette.picked : Palette.piece
      ..style = PaintingStyle.stroke
      ..strokeWidth = reach * 0.22
      ..strokeJoin = StrokeJoin.round;

    switch (piece) {
      // A small disc. The least of the pieces gets the least of the ink.
      case Piece.pawn:
        canvas.drawCircle(middle, reach * 0.38, fill);

      // A triangle, pointing the way it jumps.
      case Piece.knight:
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx, middle.dy - reach * 0.62)
            ..lineTo(middle.dx + reach * 0.58, middle.dy + reach * 0.46)
            ..lineTo(middle.dx - reach * 0.58, middle.dy + reach * 0.46)
            ..close(),
          fill,
        );

      // A diamond: a square stood on its corner, which is how it moves.
      case Piece.bishop:
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx, middle.dy - reach * 0.66)
            ..lineTo(middle.dx + reach * 0.66, middle.dy)
            ..lineTo(middle.dx, middle.dy + reach * 0.66)
            ..lineTo(middle.dx - reach * 0.66, middle.dy)
            ..close(),
          fill,
        );

      // A square, flat on, which is also how it moves.
      case Piece.rook:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: middle,
              width: reach * 1.06,
              height: reach * 1.06,
            ),
            Radius.circular(reach * 0.12),
          ),
          fill,
        );

      // Both of those at once: a square with its corners out.
      case Piece.queen:
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx, middle.dy - reach * 0.72)
            ..lineTo(middle.dx + reach * 0.30, middle.dy - reach * 0.30)
            ..lineTo(middle.dx + reach * 0.72, middle.dy)
            ..lineTo(middle.dx + reach * 0.30, middle.dy + reach * 0.30)
            ..lineTo(middle.dx, middle.dy + reach * 0.72)
            ..lineTo(middle.dx - reach * 0.30, middle.dy + reach * 0.30)
            ..lineTo(middle.dx - reach * 0.72, middle.dy)
            ..lineTo(middle.dx - reach * 0.30, middle.dy - reach * 0.30)
            ..close(),
          fill,
        );

      // A ring with a cross on it, which is the one piece everybody draws the
      // same way.
      case Piece.king:
        canvas
          ..drawCircle(
            middle,
            reach * 0.50,
            Paint()
              ..color = fill.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = reach * 0.20,
          )
          ..drawLine(
            Offset(middle.dx, middle.dy - reach * 0.86),
            Offset(middle.dx, middle.dy - reach * 0.42),
            line,
          )
          ..drawLine(
            Offset(middle.dx - reach * 0.22, middle.dy - reach * 0.64),
            Offset(middle.dx + reach * 0.22, middle.dy - reach * 0.64),
            line,
          );
    }
  }

  @override
  bool shouldRepaint(_ManPainter old) =>
      old.piece != piece || old.picked != picked;
}
