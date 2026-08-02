import 'package:flutter/material.dart';

import 'palette.dart';

/// The mark: the runner in the air, over the gap.
///
/// The whole game is one shape leaving one edge and not quite reaching the
/// next, so that is the picture. It reads at forty eight points, which is the
/// size that decides these things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onSky = true});

  /// Whether to draw the sky behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onSky;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onSky: onSky),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onSky});

  final bool onSky;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onSky) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.14)),
        Paint()..color = Palette.sky,
      );
    }

    // Two ledges with a gap between them, low in the frame.
    final floor = box.top + side * 0.72;
    final ground = Paint()..color = Palette.ground;
    final edge = Paint()..color = Palette.edge;

    for (final ledge in [
      Rect.fromLTRB(box.left, floor, box.left + side * 0.34, box.bottom),
      Rect.fromLTRB(box.right - side * 0.30, floor, box.right, box.bottom),
    ]) {
      canvas.drawRect(ledge, ground);
      canvas.drawRect(
        Rect.fromLTWH(ledge.left, ledge.top, ledge.width, side * 0.03),
        edge,
      );
    }

    // The runner, up and leaning, above the gap.
    final runner = side * 0.22;
    final at = Rect.fromCenter(
      center: Offset(box.center.dx + side * 0.02, floor - side * 0.24),
      width: runner,
      height: runner,
    );

    canvas.save();
    canvas.translate(at.center.dx, at.center.dy);
    canvas.rotate(0.3);
    canvas.translate(-at.center.dx, -at.center.dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        at.translate(0, runner * 0.08),
        Radius.circular(runner * 0.26),
      ),
      Paint()..color = Palette.runnerDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(at, Radius.circular(runner * 0.26)),
      Paint()..color = Palette.runner,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onSky != onSky;
}
