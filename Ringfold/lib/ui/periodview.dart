import 'dart:math';

import 'package:flutter/material.dart';

import '../period/play.dart';
import 'palette.dart';

/// Where the clock sits in a board of a given size: the hours round a
/// ring, 0 at the top, running clockwise.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare ? 0.0 : (roomy ? 30.0 : 0.0);
    final side = min(size.width, size.height - strip);
    centre = Offset(size.width / 2, (size.height - strip) / 2);
    radius = side / 2 - (bare ? 8 : 26);
  }

  final Play play;
  final Size size;
  late final Offset centre;
  late final double radius;

  Offset hourAt(int h) {
    final a = 2 * pi * (h % play.clock) / play.clock;
    return centre + Offset(sin(a), -cos(a)) * radius;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The clock and the Fibonacci walk round it, one period long.
class PeriodView extends CustomPainter {
  const PeriodView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the clock and the walk only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final clock = play.clock, cycle = play.cycle;
    canvas.drawCircle(m.centre, m.radius, Paint()..color = Palette.face..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
    // The walk: each Fibonacci number to the next, round and home again.
    final stroke = Paint()..color = Palette.walk..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : (cycle.length > 40 ? 1.2 : 1.8)..strokeCap = StrokeCap.round;
    for (var i = 0; i < cycle.length; i++) {
      final from = m.hourAt(cycle[i]), to = m.hourAt(cycle[(i + 1) % cycle.length]);
      if ((from - to).distance < 1) {
        // Two of a kind in a row, 1 to 1: a small loop, just inside the
        // ring where the labels are not.
        canvas.drawCircle(from - (from - m.centre) / (from - m.centre).distance * 9, 5, stroke);
      } else {
        canvas.drawLine(from, to, stroke);
      }
    }
    final landed = cycle.toSet();
    final showLabels = !bare && clock <= 31 && m.radius >= 40;
    for (var h = 0; h < clock; h++) {
      final at = m.hourAt(h);
      final lit = landed.contains(h);
      canvas.drawCircle(at, bare ? 6 : (clock > 24 ? 3.5 : 4.5), Paint()..color = lit ? Palette.landed : Palette.hourDim);
      if (h == 0 || h == 1 % clock) {
        canvas.drawCircle(at, bare ? 10 : 8, Paint()..color = Palette.home..style = PaintingStyle.stroke..strokeWidth = 2);
      }
      if (showLabels) {
        final out = (at - m.centre) / (at - m.centre).distance;
        _word(canvas, '$h', at + out * 13, lit ? Palette.ink : Palette.inkDim, size, 10);
      }
    }
    if (bare || !m.roomy) return;
    final n = cycle.length;
    _word(
      canvas,
      'period $n, ${n.isEven ? 'even' : 'odd'}: ${landed.length} of the $clock hours landed on',
      Offset(size.width / 2, size.height - 12),
      n.isEven ? Palette.inkDim : Palette.odd,
      size,
      12,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize))),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(PeriodView old) => old.play != play || old.bare != bare;
}
