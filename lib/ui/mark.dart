import 'package:flutter/material.dart';

import 'palette.dart';

/// The mark: a stroke of chalk with the ball rolling down it.
///
/// The whole game in one picture — a line somebody drew, and something running
/// along it towards the ring. It reads at forty eight points, which is the
/// size that decides these things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onSlate = true});

  /// Whether to draw the slate behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onSlate;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onSlate: onSlate),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onSlate});

  final bool onSlate;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onSlate) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.16)),
        Paint()..color = Palette.slate,
      );
    }

    Offset at(double x, double y) =>
        Offset(box.left + side * x, box.top + side * y);

    // The ring, low and to the right, where the line is pointing.
    canvas.drawCircle(
      at(0.74, 0.73),
      side * 0.115,
      Paint()
        ..color = Palette.ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.05,
    );

    // The stroke: one curve from high left down to the ring, drawn the way a
    // chalk line is — thick, round-ended, and not quite straight.
    final chalk = Path()
      ..moveTo(at(0.17, 0.31).dx, at(0.17, 0.31).dy)
      ..cubicTo(
        at(0.33, 0.45).dx, at(0.33, 0.45).dy, //
        at(0.42, 0.63).dx, at(0.42, 0.63).dy,
        at(0.64, 0.68).dx, at(0.64, 0.68).dy,
      );
    canvas.drawPath(
      chalk,
      Paint()
        ..color = Palette.chalk
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.075
        ..strokeCap = StrokeCap.round,
    );

    // The ball, resting on the line and about to go. Its middle is the width
    // of the chalk plus its own radius out from the curve, so it sits on the
    // line rather than in it.
    canvas.drawCircle(
      at(0.315, 0.298),
      side * 0.105,
      Paint()..color = Palette.ball,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onSlate != onSlate;
}
