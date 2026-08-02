import 'package:flutter/material.dart';

import 'palette.dart';
import 'peg.dart';

/// The mark: four pegs in a row, two of them read and two of them not.
///
/// The whole game in four shapes. It reads at forty eight points, which is
/// the size that decides these things — and it reads in grey as well, because
/// every peg carries a shape as well as a colour.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBench = true});

  /// Whether to draw the bench behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onBench;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onBench: onBench),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onBench});

  final bool onBench;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onBench) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.16)),
        Paint()..color = Palette.bench,
      );
    }

    // Two pegs above and two below, and one hole where the fourth would be.
    // Three colours known and one still to find is what the game is.
    const wide = 0.30;
    final peg = side * wide;
    final gap = side * 0.06;
    final left = box.left + (side - (peg * 2 + gap)) / 2;
    final top = box.top + (side - (peg * 2 + gap)) / 2;

    void draw(int row, int column, int colour, {bool empty = false}) {
      canvas.save();
      canvas.translate(left + column * (peg + gap), top + row * (peg + gap));
      PegPainter(colour: colour, empty: empty, lit: false)
          .paint(canvas, Size(peg, peg));
      canvas.restore();
    }

    draw(0, 0, 0);
    draw(0, 1, 4);
    draw(1, 0, 2);
    draw(1, 1, 0, empty: true);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onBench != onBench;
}
