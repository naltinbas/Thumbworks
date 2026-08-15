import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../rope/play.dart';
import '../rope/rules.dart';
import 'palette.dart';

/// Where the knots lie on the board, so the screen and the tests can
/// find every one: the rope runs straight across the top band, and
/// the triangle it makes stands on the sand below.
class Metrics {
  Metrics(this.play, Size room) {
    final knots = play.rope.knots;
    left = room.width * 0.06;
    right = room.width * 0.94;
    ropeY = room.height * 0.1;
    gap = (right - left) / knots;
    plot = Rect.fromLTRB(room.width * 0.05, room.height * 0.2, room.width * 0.95, room.height * 0.98);
  }

  final Play play;

  late final double left;
  late final double right;
  late final double ropeY;
  late final double gap;
  late final Rect plot;

  /// Where knot [k] sits on the straight rope; knot nought is the
  /// home peg at the left end, and the rope's far end is knot nought
  /// again.
  Offset at(int k) => Offset(left + k * gap, ropeY);

  /// The knot under a touch, or null off the rope band.
  int? under(Offset touch) {
    if ((touch.dy - ropeY).abs() > gap * 3 && (touch.dy - ropeY).abs() > 28) return null;
    final k = ((touch.dx - left) / gap).round();
    if (k < 1 || k >= play.rope.knots) return null;
    return k;
  }
}

/// The rope, the pegs on it, and the triangle they stretch on the
/// sand: knots along every side, the lengths written, the corner
/// across from the longest side marked square in green or shown
/// short or over in rust.
class RopeView extends CustomPainter {
  RopeView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final knots = play.rope.knots;
    final gap = metrics.gap;

    // The rope, straight, with its knots.
    final ropePaint = Paint()
      ..color = Palette.rope
      ..strokeWidth = math.max(3.0, gap * 0.35)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(metrics.at(0), metrics.at(knots), ropePaint);
    for (var k = 0; k <= knots; k++) {
      final r = k % 5 == 0 ? math.max(2.2, gap * 0.28) : math.max(1.6, gap * 0.2);
      canvas.drawCircle(metrics.at(k), r, Paint()..color = Palette.knot);
    }
    // The home peg at both ends, dim, and the two pegs set.
    for (final end in [0, knots]) {
      canvas.drawCircle(metrics.at(end), math.max(5, gap * 0.6), Paint()..color = Palette.pegDim);
    }
    for (var n = 0; n < play.marks.length; n++) {
      final at = metrics.at(play.marks[n]);
      canvas.drawCircle(at, math.max(6, gap * 0.7), Paint()..color = Palette.peg);
      _write(canvas, '${play.marks[n]}', at + Offset(0, -math.max(12.0, gap * 1.4)),
          labels.copyWith(color: Palette.peg, fontSize: 12, fontWeight: FontWeight.w700));
    }
    // The pointer on the rope.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        metrics.at(aim.$2),
        math.max(10, gap * 1.1),
        Paint()
          ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // The sand plot.
    final plot = metrics.plot;
    canvas.drawRRect(RRect.fromRectAndRadius(plot, const Radius.circular(10)), Paint()..color = Palette.sand);
    canvas.drawRRect(
        RRect.fromRectAndRadius(plot, const Radius.circular(10)),
        Paint()
          ..color = Palette.sandEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    final sides = play.sides;
    if (sides == null) {
      _write(canvas, play.marks.isEmpty
              ? 'Stand two pegs on the rope and the triangle is stretched here.'
              : 'One peg stands; the second closes the triangle.',
          plot.center, labels.copyWith(color: Palette.sandInk, fontSize: 13));
      return;
    }
    _triangle(canvas, metrics, sides);
  }

  void _triangle(Canvas canvas, Metrics metrics, Sides sides) {
    final (a, b, c) = sides;
    final plot = metrics.plot.deflate(metrics.plot.width * 0.09);
    // Home at A, the first peg at B along the base, the second peg at C.
    final ad = a.toDouble(), bd = b.toDouble(), cd = c.toDouble();
    final closes = Rules.closes(sides);
    late Offset pa, pb, pc;
    if (closes) {
      final x = (ad * ad + cd * cd - bd * bd) / (2 * ad);
      final y = math.sqrt(math.max(0, cd * cd - x * x));
      pa = Offset.zero;
      pb = Offset(ad, 0);
      pc = Offset(x, -y);
    } else {
      // The rope will not close: lay the sides flat, the gap showing.
      pa = Offset.zero;
      pb = Offset(ad, 0);
      pc = Offset(ad + bd, 0);
    }
    var minX = math.min(pa.dx, math.min(pb.dx, pc.dx)), maxX = math.max(pa.dx, math.max(pb.dx, pc.dx));
    var minY = math.min(pa.dy, math.min(pb.dy, pc.dy)), maxY = math.max(pa.dy, math.max(pb.dy, pc.dy));
    if (!closes) {
      maxX = math.max(maxX, cd);
      minY = -1;
    }
    final w = maxX - minX, h = maxY - minY;
    final scale = math.min(plot.width / math.max(w, 1e-9), plot.height / math.max(h, 1e-9)) * 0.92;
    final centre = plot.center;
    Offset put(Offset p) => centre + Offset((p.dx - (minX + maxX) / 2) * scale, (p.dy - (minY + maxY) / 2) * scale);
    final qa = put(pa), qb = put(pb), qc = put(pc);

    final ropePaint = Paint()
      ..color = Palette.rope
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(qa, qb, ropePaint);
    canvas.drawLine(qb, qc, ropePaint);
    if (closes) {
      canvas.drawLine(qc, qa, ropePaint);
    } else {
      // The last side runs back from home, and falls short of C.
      canvas.drawLine(qa, put(Offset(cd, 0)) + const Offset(0, 14), ropePaint);
    }
    // Knots along the sides.
    void knotsAlong(Offset from, Offset to, int count) {
      for (var k = 1; k < count; k++) {
        canvas.drawCircle(Offset.lerp(from, to, k / count)!, 2.4, Paint()..color = Palette.knot);
      }
    }

    knotsAlong(qa, qb, a);
    knotsAlong(qb, qc, b);
    if (closes) knotsAlong(qc, qa, c);
    // The pegs at the corners.
    for (final q in [qa, qb, qc]) {
      canvas.drawCircle(q, 7, Paint()..color = q == qa ? Palette.pegDim : Palette.peg);
    }
    // The lengths beside the sides.
    final ink = labels.copyWith(color: Palette.sandInk, fontSize: 14, fontWeight: FontWeight.w800);
    _write(canvas, '$a', Offset.lerp(qa, qb, 0.5)! + const Offset(0, 16), ink);
    _write(canvas, '$b', Offset.lerp(qb, qc, 0.5)! + _outward(qb, qc, qa, 16), ink);
    if (closes) _write(canvas, '$c', Offset.lerp(qc, qa, 0.5)! + _outward(qc, qa, qb, 16), ink);

    // The corner across from the longest side.
    if (closes) {
      final longest = Rules.longest(sides);
      final corner = longest == a ? qc : longest == b ? qa : qb;
      final arms = longest == a ? (qb, qa) : longest == b ? (qb, qc) : (qa, qc);
      final short = Rules.shortfall(sides);
      final u = (arms.$1 - corner) / (arms.$1 - corner).distance;
      final v = (arms.$2 - corner) / (arms.$2 - corner).distance;
      final d = 18.0;
      if (short == 0) {
        final path = Path()
          ..moveTo(corner.dx + u.dx * d, corner.dy + u.dy * d)
          ..lineTo(corner.dx + (u.dx + v.dx) * d, corner.dy + (u.dy + v.dy) * d)
          ..lineTo(corner.dx + v.dx * d, corner.dy + v.dy * d);
        canvas.drawPath(path, Paint()
          ..color = Palette.square
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
        canvas.drawCircle(corner + (u + v) * d * 0.5, 2.5, Paint()..color = Palette.square);
      } else {
        final start = math.atan2(u.dy, u.dx), end = math.atan2(v.dy, v.dx);
        var sweep = end - start;
        while (sweep <= -math.pi) {
          sweep += 2 * math.pi;
        }
        while (sweep > math.pi) {
          sweep -= 2 * math.pi;
        }
        canvas.drawArc(Rect.fromCircle(center: corner, radius: d), start, sweep, false, Paint()
          ..color = Palette.off
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
        _write(canvas, short > 0 ? '$short over' : '${-short} short', corner + (u + v) * d * 1.9,
            labels.copyWith(color: Palette.off, fontSize: 12, fontWeight: FontWeight.w700));
      }
    } else {
      _write(canvas, 'no triangle: $a + $b is not more than $c', Offset(metrics.plot.center.dx, qa.dy + 40),
          labels.copyWith(color: Palette.off, fontSize: 13, fontWeight: FontWeight.w700));
    }
  }

  Offset _outward(Offset p, Offset q, Offset other, double by) {
    final mid = Offset.lerp(p, q, 0.5)!;
    var n = Offset(-(q - p).dy, (q - p).dx);
    n = n / n.distance;
    if ((mid + n - other).distance < (mid - n - other).distance) n = -n;
    return n * by;
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 260);
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(RopeView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a rope as it stands.
String whyWords(Play play) {
  final rope = play.rope;
  final note = rope.note == null ? '' : ' ${rope.note}';
  if (!rope.winnable) {
    return 'The corner is square exactly when the two short sides squared add '
        'up to the long side squared. Every square leaves nought or one when '
        'divided by four, so if the two short sides are both odd their squares '
        'add to two over a multiple of four, which no square is; so at most one '
        'short side is odd, and then the long side\'s square has the same '
        'remainder, and the sides come to an even total either way. The rope '
        'here has an odd number of knots, and the sweep of its 276 markings '
        'finds no square corner, nor on any odd rope to two hundred.$note';
  }
  return 'The sweep stands the two pegs every way and reads each corner two '
      'ways that must agree: by the squares, whether the two short sides '
      'squared add to the long side squared, and by Euclid\'s formula, which '
      'writes down every right triangle with whole sides from two numbers m and '
      'n and finds this rope\'s without searching. ${rope.ways} markings of the '
      '${rope.markings} land it.$note';
}
