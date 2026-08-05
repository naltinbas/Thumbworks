import 'package:flutter/material.dart';

import 'palette.dart';

/// The mark: a cairn of stones with the top one coming off.
///
/// The whole game in one shape, and it reads at forty eight points — which is
/// the size that decides these things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onMoor = true});

  /// Whether to draw the ground behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onMoor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onMoor: onMoor),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onMoor});

  final bool onMoor;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onMoor) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.16)),
        Paint()..color = Palette.moor,
      );
    }

    // A cairn: wide stones at the bottom, narrower going up. Drawn as
    // rounded slabs rather than circles, because a pile of circles is a bunch
    // of grapes.
    final stones = <(double, double, double)>[
      (0.50, 0.76, 0.56),
      (0.50, 0.62, 0.44),
      (0.50, 0.49, 0.34),
      (0.50, 0.37, 0.24),
    ];
    for (final (middle, down, wide) in stones) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              box.left + side * middle,
              box.top + side * down,
            ),
            width: side * wide,
            height: side * 0.10,
          ),
          Radius.circular(side * 0.05),
        ),
        Paint()..color = Palette.stone,
      );
    }

    // And the one coming off the top, in the colour of a move.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(box.left + side * 0.63, box.top + side * 0.22),
          width: side * 0.18,
          height: side * 0.10,
        ),
        Radius.circular(side * 0.05),
      ),
      Paint()..color = Palette.going,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onMoor != onMoor;
}
