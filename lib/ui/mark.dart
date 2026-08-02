import 'package:flutter/material.dart';

import 'palette.dart';

/// The mark: a crate, a mark on the floor, and the shove between them.
///
/// The whole game in three shapes. It reads at forty eight points, which is
/// the size that decides these things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onGround = true});

  /// Whether to draw the ground behind it. Off for the Android adaptive icon,
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
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onGround) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.16)),
        Paint()..color = Palette.floor,
      );
    }

    Rect cellAt(double x, double y, double wide) => Rect.fromLTWH(
          box.left + side * x,
          box.top + side * y,
          side * wide,
          side * wide,
        );

    // The mark on the floor, on the right, where the crate is going.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        cellAt(0.60, 0.37, 0.26),
        Radius.circular(side * 0.02),
      ),
      Paint()
        ..color = Palette.mark
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.045,
    );

    // The crate, on the left, mid-shove.
    final crate = cellAt(0.14, 0.37, 0.26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(crate, Radius.circular(side * 0.035)),
      Paint()..color = Palette.crate,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        crate.deflate(side * 0.055),
        Radius.circular(side * 0.02),
      ),
      Paint()
        ..color = Palette.crateEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.035,
    );

    // The shove: an arrow from the crate to the mark.
    final middle = box.top + side * 0.50;
    canvas.drawLine(
      Offset(crate.right + side * 0.025, middle),
      Offset(box.left + side * 0.54, middle),
      Paint()
        ..color = Palette.ink
        ..strokeWidth = side * 0.05
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(box.left + side * 0.58, middle)
        ..lineTo(box.left + side * 0.50, middle - side * 0.06)
        ..lineTo(box.left + side * 0.50, middle + side * 0.06)
        ..close(),
      Paint()..color = Palette.ink,
    );

    // And whoever is doing the shoving, behind the crate.
    canvas.drawCircle(
      Offset(box.left + side * 0.075, middle),
      side * 0.075,
      Paint()..color = Palette.hauler,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onGround != onGround;
}
