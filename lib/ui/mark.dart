import 'package:flutter/material.dart';

import 'palette.dart';

/// The mark: the middle of the board, where the game starts and usually ends.
///
/// The king ringed in gold, his four guards around him, and four raiders
/// closing in on the diagonals. It is the opening position with everything
/// beyond the first ring cropped away, which is the smallest picture that is
/// still recognisably this game — and small matters, because the same drawing
/// is the logo at five hundred pixels and the app icon at forty eight.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBoard = true});

  /// Whether to draw the board under it. Off for the Android adaptive icon,
  /// where the background is a layer of its own and the launcher may crop
  /// whatever is over it to a circle.
  final bool onBoard;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onBoard: onBoard),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onBoard});

  final bool onBoard;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final board = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
    final step = side / 3;
    Offset at(double col, double row) =>
        Offset(board.left + (col + 0.5) * step, board.top + (row + 0.5) * step);

    if (onBoard) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(board, Radius.circular(side * 0.14)),
        Paint()..color = Palette.board,
      );

      final rule = Paint()
        ..color = Palette.rule
        ..strokeWidth = side * 0.012;
      for (var i = 1; i < 3; i++) {
        canvas.drawLine(
          Offset(board.left + i * step, board.top + side * 0.08),
          Offset(board.left + i * step, board.bottom - side * 0.08),
          rule,
        );
        canvas.drawLine(
          Offset(board.left + side * 0.08, board.top + i * step),
          Offset(board.right - side * 0.08, board.top + i * step),
          rule,
        );
      }
    }

    // The raiders, on the diagonals, coming in.
    final raider = Paint()..color = Palette.raider;
    for (final corner in const [[0.0, 0.0], [2.0, 0.0], [0.0, 2.0], [2.0, 2.0]]) {
      canvas.drawCircle(at(corner[0], corner[1]), step * 0.29, raider);
    }

    // The guards, holding the four sides.
    final guard = Paint()..color = Palette.guard;
    for (final beside in const [[1.0, 0.0], [0.0, 1.0], [2.0, 1.0], [1.0, 2.0]]) {
      canvas.drawCircle(at(beside[0], beside[1]), step * 0.31, guard);
    }

    // The king.
    final middle = at(1, 1);
    canvas.drawCircle(middle, step * 0.36, Paint()..color = Palette.king);
    canvas.drawCircle(
      middle,
      step * 0.19,
      Paint()
        ..color = onBoard ? Palette.board : Palette.night
        ..style = PaintingStyle.stroke
        ..strokeWidth = step * 0.09,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onBoard != onBoard;
}
