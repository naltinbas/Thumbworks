import 'dart:math';

import 'package:flutter/material.dart';

import '../wait/play.dart';
import '../wait/rules.dart';
import 'palette.dart';

/// Where the hour and the waits sit in a board of a given size: the
/// hour runs along a strip near the bottom, and the wait at each minute
/// stands above it.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    if (bare) {
      final room = min(size.width, size.height);
      left = (size.width - room) / 2 + room * 0.04;
      width = room * 0.92;
      stripY = (size.height + room) / 2 - room * 0.14;
      tall = room * 0.66;
      return;
    }
    left = 16;
    width = size.width - 32;
    stripY = size.height - strip - 30;
    tall = max(20, stripY - 40);
  }

  /// The tallest wait the board makes room for: the worst timetable's,
  /// or the mark's own.
  int get top => bare ? max(1, play.longest) : 57;

  final bool bare;

  final Play play;
  final Size size;
  late final double left, width, stripY, tall;

  /// Where minute [t] of the hour falls along the strip.
  double xAt(double t) => left + width * t / Rules.hour;

  /// The height a wait of [w] minutes stands at.
  double yAt(double w) => stripY - tall * w / top;

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The hour, the buses, the wait at every minute, the average and the
/// fair line.
class WaitView extends CustomPainter {
  const WaitView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: ('g1' or 'g2', by).
  final (String, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the waits and the buses only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final gaps = play.gaps;
    final thick = bare ? m.width * 0.012 : 2.0;
    // The waits, a tooth a gap, filled faint and drawn in copper.
    final fill = Path()..moveTo(m.xAt(0), m.stripY);
    final line = Path();
    for (var t = 0; t <= Rules.hour; t++) {
      final w = t == Rules.hour ? 0 : Rules.waitAt(gaps, t);
      final p = Offset(m.xAt(t.toDouble()), m.yAt(w.toDouble()));
      fill.lineTo(p.dx, p.dy);
      if (t == 0) {
        line.moveTo(p.dx, p.dy);
      } else {
        line.lineTo(p.dx, p.dy);
      }
    }
    fill.lineTo(m.xAt(Rules.hour.toDouble()), m.stripY);
    fill.close();
    canvas.drawPath(fill, Paint()..color = Palette.copperDim);
    canvas.drawPath(line, Paint()..color = Palette.copper..style = PaintingStyle.stroke..strokeWidth = thick..strokeJoin = StrokeJoin.round);
    // The average, in gold, and the fair line, dashed.
    final avg = play.wait.toDouble;
    canvas.drawLine(Offset(m.left, m.yAt(avg)), Offset(m.left + m.width, m.yAt(avg)), Paint()..color = Palette.gold..strokeWidth = thick * 1.2);
    final fair = Rules.fairWait.toDouble;
    _dashed(canvas, Offset(m.left, m.yAt(fair)), Offset(m.left + m.width, m.yAt(fair)), Paint()..color = bare ? Palette.inkDim : Palette.inkDim..strokeWidth = thick * 0.8);
    // The hour strip and the buses.
    canvas.drawRect(Rect.fromLTWH(m.left, m.stripY, m.width, bare ? m.width * 0.03 : 6), Paint()..color = Palette.strip);
    if (!bare) {
      for (var t = 0; t <= Rules.hour; t += 10) {
        canvas.drawLine(Offset(m.xAt(t.toDouble()), m.stripY + 6), Offset(m.xAt(t.toDouble()), m.stripY + 10), Paint()..color = Palette.line..strokeWidth = 1);
        _word(canvas, '$t', Offset(m.xAt(t.toDouble()), m.stripY + 18), Palette.inkDim, size, 10);
      }
    }
    for (final b in [...Rules.busesAt(gaps), Rules.hour]) {
      final r = bare ? m.width * 0.03 : 5.0;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(m.xAt(b.toDouble()), m.stripY + (bare ? m.width * 0.015 : 3)), width: r * 2.2, height: r * 2.2), Radius.circular(r * 0.5)), Paint()..color = Palette.bus);
    }
    if (bare) return;
    // The labels: the average and the fair, kept apart.
    final avgY = m.yAt(avg), fairY = m.yAt(fair);
    _word(canvas, 'average ${Rules.tell(play.wait)}', Offset(m.left + m.width - 50, avgY - 10), Palette.gold, size, 11);
    _word(canvas, 'fair ${Rules.tell(Rules.fairWait)}', Offset(m.left + 40, fairY + (avgY - fairY).abs() < 16 ? fairY + 12 : fairY - 10), Palette.inkDim, size, 11);
    if (!m.roomy) return;
    _word(canvas, 'gaps ${Rules.tellGaps(gaps)}: longest wait ${play.longest} minute${play.longest == 1 ? '' : 's'}', Offset(size.width / 2, size.height - 11), Palette.inkDim, size, 12);
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final d = to - from;
    final length = d.distance;
    final unit = d / length;
    var run = 0.0;
    while (run < length) {
      final end = min(run + 6, length);
      canvas.drawLine(from + unit * run, from + unit * end, paint);
      run += 11;
    }
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool bold = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize), fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(WaitView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
