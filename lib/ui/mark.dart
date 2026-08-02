import 'package:flutter/material.dart';

import '../sim/kinds.dart';
import 'palette.dart';

/// The mark: a bend of lane with something built beside it.
///
/// The smallest picture that is still this game — a path that turns, and a
/// tower covering the turn, which is the whole of what a player thinks about.
/// Small matters, because the same drawing is the logo at five hundred pixels
/// and the app icon at forty eight.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onGround = true});

  /// Whether to draw the ground under it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onGround;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onGround: onGround),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onGround});

  final bool onGround;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final field = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
    final cell = side / 4;
    Rect at(int col, int row) => Rect.fromLTWH(
          field.left + col * cell,
          field.top + row * cell,
          cell,
          cell,
        );

    if (onGround) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(field, Radius.circular(side * 0.14)),
        Paint()..color = Palette.ground,
      );
    }

    // The lane: in at the top, one turn, out at the right.
    final lane = Paint()..color = Palette.lane;
    for (final cell in const [[1, 0], [1, 1], [1, 2], [2, 2], [3, 2]]) {
      canvas.drawRect(at(cell[0], cell[1]), lane);
    }
    canvas.drawRect(at(3, 2), Paint()..color = Palette.keep.withValues(alpha: 0.55));

    // A forge on the outside of the turn, where it covers both stretches, and
    // a spark on the inside.
    void tower(int col, int row, Tower kind) {
      final box = at(col, row).deflate(cell * 0.17);
      final tint = Palette.of(kind);
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(cell * 0.16)),
        Paint()..color = tint.withValues(alpha: 0.25),
      );
      if (kind == Tower.forge) {
        canvas.drawRect(
          Rect.fromCenter(
            center: box.center,
            width: box.width * 0.56,
            height: box.width * 0.56,
          ),
          Paint()..color = tint,
        );
      } else {
        canvas.drawCircle(box.center, box.width * 0.3, Paint()..color = tint);
      }
    }

    tower(2, 1, Tower.spark);
    tower(0, 2, Tower.forge);

    // And a shot across the lane, which is the thing the whole game is for.
    canvas.drawLine(
      at(2, 1).center,
      at(1, 1).center,
      Paint()
        ..color = Palette.of(Tower.spark)
        ..strokeWidth = cell * 0.09
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onGround != onGround;
}
