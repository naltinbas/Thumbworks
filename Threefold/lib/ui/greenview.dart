import 'dart:math';

import 'package:flutter/material.dart';

import '../green/play.dart';
import '../green/rules.dart';
import 'palette.dart';

/// Where the green sits in a board of a given size: lattice to pixels.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 22.0 : 0.0;
    final h = (size.height - strip - 24), w = size.width - 24;
    // The side in pixels: fits the width, and the height sqrt(3)/2 of it.
    unit = min(w / Rules.side, h / (Rules.side * sqrt(3) / 2));
    final sidePx = unit * Rules.side, heightPx = sidePx * sqrt(3) / 2;
    left = (size.width - sidePx) / 2;
    floor = (size.height - strip) / 2 + heightPx / 2;
  }

  final Play play;
  final Size size;
  late final double unit, left, floor;

  /// A lattice point (rungs) to pixels.
  Offset at((int, int, int) p) {
    final (dx, dy) = Rules.doubled(p);
    return Offset(left + dx * unit / 2, floor - dy * unit * sqrt(3) / 2);
  }

  Offset get leftCorner => at((0, 12, 0));
  Offset get rightCorner => at((0, 0, 12));
  Offset get top => at((12, 0, 0));

  /// The lattice point under a pixel, or null.
  (int, int, int)? under(Offset q) {
    (int, int, int)? best;
    var bestD = unit * 0.5;
    for (final p in Rules.points) {
      final d = (at(p) - q).distance;
      if (d < bestD) {
        bestD = d;
        best = p;
      }
    }
    return best;
  }

  /// The foot of the perpendicular from [p] to a side, floor 0, right
  /// slope 1, left slope 2.
  Offset foot(Offset p, int side) {
    final a = side == 0 ? leftCorner : side == 1 ? rightCorner : top;
    final b = side == 0 ? rightCorner : side == 1 ? top : leftCorner;
    final ab = b - a;
    final t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / (ab.dx * ab.dx + ab.dy * ab.dy);
    return a + ab * t;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The green, the lattice, the walker and the three distances.
class GreenView extends CustomPainter {
  const GreenView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the green only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final green = Path()
      ..moveTo(m.leftCorner.dx, m.leftCorner.dy)
      ..lineTo(m.rightCorner.dx, m.rightCorner.dy)
      ..lineTo(m.top.dx, m.top.dy)
      ..close();
    canvas.drawPath(green, Paint()..color = Palette.turf);
    canvas.drawPath(
      green,
      Paint()
        ..color = Palette.turfRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 6 : 2.5,
    );
    if (!bare) {
      for (final p in Rules.points) {
        canvas.drawCircle(m.at(p), 2, Paint()..color = Palette.dot);
      }
    }
    // The three perpendiculars from the walker.
    final w = m.at(play.at);
    final inks = [Palette.floorInk, Palette.rightInk, Palette.leftInk];
    final rungs = [play.at.$1, play.at.$2, play.at.$3];
    for (var s = 0; s < 3; s++) {
      final f = m.foot(w, s);
      canvas.drawLine(w, f, Paint()..color = inks[s]..strokeWidth = bare ? 5 : 3);
      if (!bare && m.roomy && rungs[s] > 0) {
        _word(canvas, '${rungs[s]}', (w + f) / 2 + Offset(s == 0 ? 10 : 0, s == 0 ? 0 : -10), inks[s], size);
      }
    }
    canvas.drawCircle(w, bare ? 12 : 7, Paint()..color = Palette.walker);
    canvas.drawCircle(w, bare ? 12 : 7, Paint()..color = Palette.night..style = PaintingStyle.stroke..strokeWidth = 1.5);
    if (bare) return;
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.at(aim), 12, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    if (!m.roomy) return;
    _word(canvas, '${play.at.$1} + ${play.at.$2} + ${play.at.$3} = ${play.sum} rungs, the height', Offset(size.width / 2, size.height - 11), Palette.inkDim, size);
  }

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
  bool shouldRepaint(GreenView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
