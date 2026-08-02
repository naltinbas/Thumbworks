import 'dart:math';

import 'package:flutter/material.dart';

import '../lock/lock.dart';
import 'palette.dart';

/// The shape each peg colour carries as well as its colour.
///
/// Eight shapes drawn on eight hues. Either on its own would do for most
/// people, and neither on its own does for everybody.
enum Shapes { dot, ring, bar, cross, triangle, chevron, square, slash }

/// One peg: a colour, and the shape that goes with it.
class Peg extends StatelessWidget {
  const Peg({
    super.key,
    required this.colour,
    this.side = 40,
    this.empty = false,
    this.lit = false,
  });

  /// Which colour, or anything at all if [empty].
  final int colour;

  final double side;

  /// An unfilled slot, drawn as a hole rather than a peg.
  final bool empty;

  /// Whether this is the slot the next colour would go into.
  final bool lit;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: side,
        height: side,
        child: CustomPaint(
          painter: PegPainter(colour: colour, empty: empty, lit: lit),
        ),
      );
}

class PegPainter extends CustomPainter {
  const PegPainter({
    required this.colour,
    required this.empty,
    required this.lit,
  });

  final int colour;
  final bool empty;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final middle = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (empty) {
      canvas.drawCircle(middle, radius * 0.80, Paint()..color = Palette.groove);
      if (lit) {
        canvas.drawCircle(
          middle,
          radius * 0.80,
          Paint()
            ..color = Palette.brass
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * 0.15,
        );
      }
      return;
    }

    canvas.drawCircle(
      middle,
      radius * 0.94,
      Paint()..color = Palette.forPeg(colour),
    );
    _paintShape(canvas, middle, radius * 0.40, Shapes.values[colour % 8]);
  }

  /// The shape on the face of a peg, in the dark of the bench so it reads on
  /// all eight colours.
  void _paintShape(Canvas canvas, Offset middle, double size, Shapes shape) {
    final dark = Palette.night.withValues(alpha: 0.72);
    final fill = Paint()..color = dark;
    Paint stroke(double wide) => Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * wide
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (shape) {
      case Shapes.dot:
        canvas.drawCircle(middle, size * 0.62, fill);
      case Shapes.ring:
        canvas.drawCircle(middle, size * 0.72, stroke(0.38));
      case Shapes.bar:
        canvas.drawLine(
          middle - Offset(size, 0),
          middle + Offset(size, 0),
          stroke(0.42),
        );
      case Shapes.cross:
        canvas
          ..drawLine(
            middle - Offset(size * 0.8, 0),
            middle + Offset(size * 0.8, 0),
            stroke(0.40),
          )
          ..drawLine(
            middle - Offset(0, size * 0.8),
            middle + Offset(0, size * 0.8),
            stroke(0.40),
          );
      case Shapes.triangle:
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx, middle.dy - size)
            ..lineTo(middle.dx + size * 0.9, middle.dy + size * 0.7)
            ..lineTo(middle.dx - size * 0.9, middle.dy + size * 0.7)
            ..close(),
          fill,
        );
      case Shapes.chevron:
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx - size * 0.8, middle.dy - size * 0.5)
            ..lineTo(middle.dx, middle.dy + size * 0.35)
            ..lineTo(middle.dx + size * 0.8, middle.dy - size * 0.5),
          stroke(0.40),
        );
      case Shapes.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: middle,
            width: size * 1.35,
            height: size * 1.35,
          ),
          fill,
        );
      case Shapes.slash:
        canvas.drawLine(
          middle + Offset(-size * 0.75, size * 0.75),
          middle + Offset(size * 0.75, -size * 0.75),
          stroke(0.42),
        );
    }
  }

  @override
  bool shouldRepaint(PegPainter old) =>
      old.colour != colour || old.empty != empty || old.lit != lit;
}

/// What a guess came back as: a filled dot for every peg in the right place,
/// a hollow one for every colour in the wrong place.
class Marking extends StatelessWidget {
  const Marking({
    super.key,
    required this.mark,
    required this.lock,
    this.side = 11,
  });

  final Mark mark;
  final Lock lock;
  final double side;

  @override
  Widget build(BuildContext context) {
    final across = max(2, (lock.pegs / 2).ceil());
    return Semantics(
      label: '${mark.blacks} right, ${mark.whites} in the wrong place',
      child: SizedBox(
        width: across * (side + 4),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (var i = 0; i < lock.pegs; i++)
              _Dot(
                side: side,
                filled: i < mark.blacks,
                hollow: i >= mark.blacks && i < mark.blacks + mark.whites,
              ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.side,
    required this.filled,
    required this.hollow,
  });

  final double side;
  final bool filled;
  final bool hollow;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: side,
        height: side,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Palette.black : Colors.transparent,
            border: Border.all(
              color: filled || hollow ? Palette.white : Palette.groove,
              width: 1.4,
            ),
          ),
        ),
      );
}
