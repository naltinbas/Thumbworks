import 'package:flutter/material.dart';

import 'palette.dart';

/// One die, with its pips where they belong.
class Die extends StatelessWidget {
  const Die({
    super.key,
    required this.face,
    this.side = 54,
    this.bad = false,
    this.doubled = false,
  });

  /// What it shows. Nought for a die that has not been thrown.
  final int face;

  final double side;

  /// Whether this is the one that ended the turn.
  final bool bad;

  /// Whether it is half of a pair, which pays double.
  final bool doubled;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: side,
        height: side,
        child: CustomPaint(
          painter: _DiePainter(face: face, bad: bad, doubled: doubled),
        ),
      );
}

class _DiePainter extends CustomPainter {
  const _DiePainter({
    required this.face,
    required this.bad,
    required this.doubled,
  });

  final int face;
  final bool bad;
  final bool doubled;

  /// Where the pips go, as fractions across and down, for each face.
  ///
  /// Written out rather than worked out. A die's pips are a shape people know
  /// by heart, and a rule that put a five's four corners a hair off would be
  /// noticed by everybody and explainable by nobody.
  static const _pips = <int, List<(double, double)>>{
    1: [(0.5, 0.5)],
    2: [(0.28, 0.28), (0.72, 0.72)],
    3: [(0.26, 0.26), (0.5, 0.5), (0.74, 0.74)],
    4: [(0.28, 0.28), (0.72, 0.28), (0.28, 0.72), (0.72, 0.72)],
    5: [
      (0.27, 0.27),
      (0.73, 0.27),
      (0.5, 0.5),
      (0.27, 0.73),
      (0.73, 0.73),
    ],
    6: [
      (0.28, 0.24),
      (0.72, 0.24),
      (0.28, 0.5),
      (0.72, 0.5),
      (0.28, 0.76),
      (0.72, 0.76),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(size.width * 0.20)),
      Paint()..color = bad ? Palette.bad : Palette.die,
    );
    if (doubled) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          box.deflate(size.width * 0.04),
          Radius.circular(size.width * 0.17),
        ),
        Paint()
          ..color = Palette.yours
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.08,
      );
    }

    final where = _pips[face];
    if (where == null) return;
    final paint = Paint()..color = bad ? Palette.die : Palette.pip;
    for (final (across, down) in where) {
      canvas.drawCircle(
        Offset(size.width * across, size.height * down),
        size.width * 0.095,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiePainter old) =>
      old.face != face || old.bad != bad || old.doubled != doubled;
}
