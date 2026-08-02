import 'package:flutter/material.dart';

import 'palette.dart';

/// The mark: two dice, one showing a one and one showing a six.
///
/// The whole game in two shapes — the throw that takes everything and the
/// throw that pays. It reads at forty eight points, which is the size that
/// decides these things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onFelt = true});

  /// Whether to draw the table behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onFelt;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onFelt: onFelt),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onFelt});

  final bool onFelt;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onFelt) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.16)),
        Paint()..color = Palette.felt,
      );
    }

    void die(Rect where, Color face, List<(double, double)> pips, Color pip) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(where, Radius.circular(where.width * 0.22)),
        Paint()..color = face,
      );
      for (final (across, down) in pips) {
        canvas.drawCircle(
          Offset(where.left + where.width * across,
              where.top + where.height * down),
          where.width * 0.115,
          Paint()..color = pip,
        );
      }
    }

    final wide = side * 0.40;
    // The six, behind and to the right: what the game pays.
    die(
      Rect.fromLTWH(box.left + side * 0.32, box.top + side * 0.22, wide, wide),
      Palette.die,
      const [
        (0.28, 0.22),
        (0.72, 0.22),
        (0.28, 0.5),
        (0.72, 0.5),
        (0.28, 0.78),
        (0.72, 0.78),
      ],
      Palette.pip,
    );
    // The one, in front and to the left: what it takes back.
    die(
      Rect.fromLTWH(box.left + side * 0.16, box.top + side * 0.40, wide, wide),
      Palette.bad,
      const [(0.5, 0.5)],
      Palette.die,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onFelt != onFelt;
}
