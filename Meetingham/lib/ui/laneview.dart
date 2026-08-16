import 'dart:math';

import 'package:flutter/material.dart';

import '../lane/play.dart';
import '../lane/rules.dart';
import 'palette.dart';

/// Where the field sits in a board of a given size: paces to pixels, A
/// at the bottom left, B at the bottom right, C at the top left.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 22.0 : 0.0;
    unit = min((size.width - 40) / Rules.paces, (size.height - strip - 40) / Rules.paces);
    origin = Offset((size.width - unit * Rules.paces) / 2, (size.height - strip) / 2 + unit * Rules.paces / 2);
  }

  final Play play;
  final Size size;
  late final double unit;
  late final Offset origin;

  /// A lattice point to pixels.
  Offset at((int, int) p) => origin + Offset(p.$1 * unit, -p.$2 * unit);

  /// The gate under a point, as (which, paces), or null: the nearest
  /// lattice point of a side within reach, D on BC, E on CA, F on AB.
  (int, int)? under(Offset q) {
    (int, int)? best;
    var bestD = unit * 0.45;
    for (var k = 1; k < Rules.paces; k++) {
      for (final (which, p) in [(0, Rules.gateD(k)), (1, Rules.gateE(k)), (2, Rules.gateF(k))]) {
        final dist = (at(p) - q).distance;
        if (dist < bestD) {
          bestD = dist;
          best = (which, k);
        }
      }
    }
    return best;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The field, the gates, the lanes and the meeting.
class LaneView extends CustomPainter {
  const LaneView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the field only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final pa = m.at(Rules.a), pb = m.at(Rules.b), pc = m.at(Rules.c);
    final field = Path()
      ..moveTo(pa.dx, pa.dy)
      ..lineTo(pb.dx, pb.dy)
      ..lineTo(pc.dx, pc.dy)
      ..close();
    canvas.drawPath(field, Paint()..color = Palette.field);
    canvas.drawPath(field, Paint()..color = Palette.hedge..style = PaintingStyle.stroke..strokeWidth = bare ? 6 : 2.5);
    // The posts along the sides where a gate may stand.
    if (!bare) {
      for (var k = 1; k < Rules.paces; k++) {
        for (final p in [Rules.gateD(k), Rules.gateE(k), Rules.gateF(k)]) {
          canvas.drawCircle(m.at(p), 2.5, Paint()..color = Palette.post);
        }
      }
    }
    // The lanes.
    final gd = m.at(Rules.gateD(play.d)), ge = m.at(Rules.gateE(play.e)), gf = m.at(Rules.gateF(play.f));
    final w = bare ? 5.0 : 2.5;
    canvas.drawLine(pa, gd, Paint()..color = Palette.laneA..strokeWidth = w);
    canvas.drawLine(pb, ge, Paint()..color = Palette.laneB..strokeWidth = w);
    canvas.drawLine(pc, gf, Paint()..color = Palette.laneC..strokeWidth = w);
    // The gates.
    for (final g in [gd, ge, gf]) {
      canvas.drawCircle(g, bare ? 10 : 6, Paint()..color = Palette.gate);
      canvas.drawCircle(g, bare ? 10 : 6, Paint()..color = Palette.night..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
    // The meeting, or the crossing of two with the third missing.
    final (nx, ny, den) = play.meetingPoint;
    final cross = m.at((0, 0)) + Offset(nx / den * m.unit, -ny / den * m.unit);
    canvas.drawCircle(cross, bare ? 9 : 5, Paint()..color = play.meet ? Palette.meeting : Palette.miss);
    if (bare) return;
    final aim = pointing;
    if (aim != null) {
      final p = aim.$1 == 0 ? Rules.gateD(aim.$2) : aim.$1 == 1 ? Rules.gateE(aim.$2) : Rules.gateF(aim.$2);
      canvas.drawCircle(m.at(p), 12, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    if (!m.roomy) return;
    _word(canvas, 'A', pa + const Offset(-10, 10), Palette.ink, size);
    _word(canvas, 'B', pb + const Offset(10, 10), Palette.ink, size);
    _word(canvas, 'C', pc + const Offset(-10, -10), Palette.ink, size);
    _word(canvas, 'D ${Rules.ratio(play.d)}', gd + const Offset(16, -10), Palette.gate, size);
    _word(canvas, 'E ${Rules.ratio(play.e)}', ge + const Offset(24, -10), Palette.gate, size);
    _word(canvas, 'F ${Rules.ratio(play.f)}', gf + const Offset(0, 12), Palette.gate, size);
    final (pn, pd) = play.product;
    final g = _gcd(pn, pd);
    _word(canvas, play.meet ? 'the lanes meet: ${pn ~/ g} to ${pd ~/ g}' : 'the lanes miss: the product is ${pn ~/ g} to ${pd ~/ g}, not 1 to 1', Offset(size.width / 2, size.height - 11), play.meet ? Palette.good : Palette.inkDim, size);
  }

  static int _gcd(int x, int y) => y == 0 ? x : _gcd(y, x % y);

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(LaneView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
