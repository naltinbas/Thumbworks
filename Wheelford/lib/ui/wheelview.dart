import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wheel/play.dart';
import '../wheel/rules.dart';
import 'palette.dart';

/// Where the pegs lie on the board, so the screen and the tests can
/// find every one.
class Metrics {
  Metrics(this.play, Size room) {
    hub = Offset(room.width / 2, room.height / 2);
    radius = math.min(room.width, room.height) * 0.38;
    unit = radius / 5;
  }

  final Play play;

  late final Offset hub;
  late final double radius;

  /// One whole-number step of a peg's place.
  late final double unit;

  /// Where a peg stands: y up on the wheel, down on the screen.
  Offset at(Peg peg) => hub + Offset(peg.$1 * unit, -peg.$2 * unit);

  /// The peg under a touch, or null.
  Peg? under(Offset touch) {
    for (final peg in Rules.pegs) {
      if ((at(peg) - touch).distance <= unit * 0.9) return peg;
    }
    return null;
  }
}

/// The wheel itself: rim, spokes and hub, the twelve pegs, the cords
/// between the corded ones, a diameter in gold and a square corner
/// marked green.
class WheelView extends CustomPainter {
  WheelView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Peg)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final r = metrics.radius;
    final unit = metrics.unit;

    // The wheel: a disc, the rim, spokes to the pegs, the hub.
    canvas.drawCircle(metrics.hub, r + unit * 0.7, Paint()..color = Palette.wheel);
    canvas.drawCircle(
      metrics.hub,
      r,
      Paint()
        ..color = Palette.rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(3, unit * 0.16),
    );
    for (final peg in Rules.pegs) {
      canvas.drawLine(metrics.hub, metrics.at(peg), Paint()
        ..color = Palette.spoke
        ..strokeWidth = math.max(1, unit * 0.05));
    }
    canvas.drawCircle(metrics.hub, unit * 0.22, Paint()..color = Palette.hub);

    // The cords between the corded pegs, in a ring.
    final pegs = play.pegs;
    final n = pegs.length;
    if (n >= 2) {
      for (var i = 0; i < n; i++) {
        final a = pegs[i], b = pegs[(i + 1) % n];
        if (n == 2 && i == 1) break;
        final diameter = Rules.isDiameter(a, b);
        canvas.drawLine(
          metrics.at(a),
          metrics.at(b),
          Paint()
            ..color = diameter ? Palette.diameter : Palette.cord
            ..strokeWidth = math.max(2, unit * (diameter ? 0.14 : 0.08))
            ..strokeCap = StrokeCap.round,
        );
      }
      // Square corners, marked with a small square in the corner.
      if (n == 3) {
        for (final i in Rules.squareCorners(pegs)) {
          final c = metrics.at(pegs[i]);
          final u = (metrics.at(pegs[(i + 1) % 3]) - c);
          final v = (metrics.at(pegs[(i + 2) % 3]) - c);
          final ul = u / u.distance * unit * 0.5;
          final vl = v / v.distance * unit * 0.5;
          final path = Path()
            ..moveTo(c.dx + ul.dx, c.dy + ul.dy)
            ..lineTo(c.dx + ul.dx + vl.dx, c.dy + ul.dy + vl.dy)
            ..lineTo(c.dx + vl.dx, c.dy + vl.dy);
          canvas.drawPath(
            path,
            Paint()
              ..color = Palette.squareMark
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(2, unit * 0.08),
          );
        }
      }
    }

    // The pegs.
    for (final peg in Rules.pegs) {
      final at = metrics.at(peg);
      final corded = pegs.contains(peg);
      final given = play.isGiven(peg);
      canvas.drawCircle(
        at,
        unit * (corded ? 0.5 : 0.36),
        Paint()..color = corded ? (given ? Palette.pegGiven : Palette.peg) : Palette.rim,
      );
      if (corded) {
        _write(
          canvas,
          '${pegs.indexOf(peg) + 1}',
          at,
          labels.copyWith(color: Palette.pegInk, fontSize: unit * 0.5, fontWeight: FontWeight.w800),
        );
      }
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        metrics.at(aim.$2),
        unit * 0.7,
        Paint()
          ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, unit * 0.1),
      );
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(WheelView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a cording as it stands.
String whyWords(Play play) {
  final cording = play.cording;
  final note = cording.note == null ? '' : ' ${cording.note}';
  if (!cording.winnable) {
    return 'Draw the spoke from the hub to the corner: it is as long as '
        'the spokes to the two far pegs, so the triangle splits into two '
        'with two equal sides each, and the corner is the sum of one '
        'base angle from each. Those two base angles add to half the '
        'triangle\'s whole, ninety degrees, exactly when the far cord '
        'runs straight through the hub. The sweep read every corner of '
        'all 220 triangles and found the square ones across a diameter '
        'every time.$note';
  }
  return 'The cordings are counted by the sweep, every three or four of '
      'the twelve pegs, and every corner is read two ways that must agree: '
      'by the dot product of its two cords, and by Thales, whether the '
      'cord across from it runs through the hub, no angle measured. '
      '${cording.ways} of the ${cording.sets} cordings land this '
      'one.$note';
}
