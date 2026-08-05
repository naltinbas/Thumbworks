import 'package:flutter/material.dart';

import 'palette.dart';

/// One lamp.
class Lamp extends StatelessWidget {
  const Lamp({
    super.key,
    required this.lit,
    required this.side,
    this.pointed = false,
  });

  final bool lit;
  final double side;

  /// Whether the game is pointing at this one.
  final bool pointed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: side,
        height: side,
        child: CustomPaint(painter: _LampPainter(lit: lit, pointed: pointed)),
      );
}

class _LampPainter extends CustomPainter {
  const _LampPainter({required this.lit, required this.pointed});

  final bool lit;
  final bool pointed;

  @override
  void paint(Canvas canvas, Size size) {
    final middle = Offset(size.width / 2, size.height / 2);
    final reach = size.shortestSide / 2;

    // The socket it sits in, so the board reads as a board rather than as a
    // scatter of dots.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: middle,
          width: reach * 1.84,
          height: reach * 1.84,
        ),
        Radius.circular(reach * 0.32),
      ),
      Paint()..color = Palette.socket,
    );

    // A lamp that is lit throws a little light on its own socket. Cheaper
    // than a shadow and it is what tells the two states apart across the
    // room.
    if (lit) {
      canvas.drawCircle(
        middle,
        reach * 0.92,
        Paint()..color = Palette.lit.withValues(alpha: 0.16),
      );
    }

    canvas
      ..drawCircle(
        middle,
        reach * 0.56,
        Paint()..color = lit ? Palette.lit : Palette.out,
      )
      ..drawCircle(
        middle,
        reach * 0.56,
        Paint()
          ..color = lit ? Palette.litEdge : Palette.outEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = reach * 0.10,
      );

    if (pointed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: middle,
            width: reach * 1.84,
            height: reach * 1.84,
          ),
          Radius.circular(reach * 0.32),
        ),
        Paint()
          ..color = Palette.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = reach * 0.14,
      );
    }
  }

  @override
  bool shouldRepaint(_LampPainter old) =>
      old.lit != lit || old.pointed != pointed;
}
