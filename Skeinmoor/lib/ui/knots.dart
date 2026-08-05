import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'palette.dart';

/// The shape on the two ends of a thread.
///
/// Colour alone would be a poor way of saying which end goes with which, and
/// on a board with eight threads it would be a bad one even for somebody who
/// sees every colour there is. So each thread has a shape as well, and the
/// shape is drawn dark on the peg. Nothing here depends on seeing colour.
enum Knots {
  disc,
  ring,
  square,
  diamond,
  triangle,
  cross,
  bar,
  star;

  static Knots of(int thread) => values[thread % values.length];
}

/// Draws the peg on one end of a thread: a round of wool with the thread's
/// shape cut out of it.
void paintKnot(
  Canvas canvas,
  Offset middle,
  double size,
  int thread, {
  bool held = false,
}) {
  final colour = Palette.woolFor(thread);
  final radius = size / 2;

  if (held) {
    canvas.drawCircle(
      middle,
      radius * 1.34,
      Paint()..color = colour.withValues(alpha: 0.28),
    );
  }
  canvas.drawCircle(middle, radius, Paint()..color = colour);

  final mark = Paint()
    ..color = Palette.night
    ..style = PaintingStyle.fill;
  final line = Paint()
    ..color = Palette.night
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.13
    ..strokeCap = StrokeCap.round;
  final inner = radius * 0.52;

  switch (Knots.of(thread)) {
    case Knots.disc:
      canvas.drawCircle(middle, inner * 0.8, mark);
    case Knots.ring:
      canvas.drawCircle(middle, inner * 0.78, line);
    case Knots.square:
      canvas.drawRect(
        Rect.fromCenter(
          center: middle,
          width: inner * 1.42,
          height: inner * 1.42,
        ),
        mark,
      );
    case Knots.diamond:
      canvas.drawPath(_polygon(middle, inner * 1.3, 4, -math.pi / 2), mark);
    case Knots.triangle:
      canvas.drawPath(_polygon(middle, inner * 1.25, 3, -math.pi / 2), mark);
    case Knots.cross:
      canvas.drawLine(
        middle + Offset(-inner, -inner),
        middle + Offset(inner, inner),
        line,
      );
      canvas.drawLine(
        middle + Offset(inner, -inner),
        middle + Offset(-inner, inner),
        line,
      );
    case Knots.bar:
      canvas.drawLine(
        middle + Offset(-inner * 1.15, 0),
        middle + Offset(inner * 1.15, 0),
        line,
      );
    case Knots.star:
      canvas.drawPath(
        _star(middle, inner * 1.25, inner * 0.52, 5, -math.pi / 2),
        mark,
      );
  }
}

/// A closed polygon: [sides] corners, all at [radius].
Path _polygon(Offset middle, double radius, int sides, double turn) {
  final path = Path();
  for (var i = 0; i < sides; i++) {
    final angle = turn + i * 2 * math.pi / sides;
    final where =
        middle + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
    if (i == 0) {
      path.moveTo(where.dx, where.dy);
    } else {
      path.lineTo(where.dx, where.dy);
    }
  }
  return path..close();
}

/// A closed path with [points] points, out to [far] and in to [near].
Path _star(Offset middle, double far, double near, int points, double turn) {
  final path = Path();
  for (var i = 0; i < points * 2; i++) {
    final angle = turn + i * math.pi / points;
    final out = i.isEven ? far : near;
    final where = middle + Offset(math.cos(angle) * out, math.sin(angle) * out);
    if (i == 0) {
      path.moveTo(where.dx, where.dy);
    } else {
      path.lineTo(where.dx, where.dy);
    }
  }
  return path..close();
}
