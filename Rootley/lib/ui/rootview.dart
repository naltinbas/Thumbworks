import 'dart:math';

import 'package:flutter/material.dart';

import '../root/play.dart';
import '../root/rules.dart';
import 'palette.dart';

/// Where the clock sits in a board of a given size: the hours round a
/// ring, 0 at the top, running clockwise.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    // A strip at the foot for the words, when there is room for them.
    final height = size.height - (roomy && !bare ? 24 : 0);
    centre = Offset(size.width / 2, height / 2);
    radius = min(size.width, height) / 2 - (bare ? 6 : 24);
  }

  final Play play;
  final Size size;
  late final Offset centre;
  late final double radius;

  /// The point of hour [h] on the ring.
  Offset hourAt(int h) {
    final a = 2 * pi * h / play.clock;
    return centre + Offset(sin(a), -cos(a)) * radius;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The clock, the walk of the base round it, and where it ends.
class RootView extends CustomPainter {
  const RootView({
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
    final clock = play.clock;
    canvas.drawCircle(m.centre, m.radius, Paint()..color = Palette.face..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
    final walk = play.walk;
    final touched = walk.toSet();
    // The hours the ask wants, ringed faintly.
    if (!bare) {
      final wanted = play.level.kind == 'all'
          ? [for (var h = 1; h < clock; h++) h]
          : play.level.kind == 'units'
              ? Rules.units(clock)
              : const <int>[];
      for (final h in wanted) {
        canvas.drawCircle(m.hourAt(h), 9, Paint()..color = Palette.wanted..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }
    // The walk, chord by chord, and the step that ends it: home in
    // gold, or astray in rust.
    final stroke = Paint()..color = Palette.walk..style = PaintingStyle.stroke..strokeWidth = bare ? 4 : 2.5..strokeCap = StrokeCap.round;
    for (var i = 0; i + 1 < walk.length; i++) {
      canvas.drawLine(m.hourAt(walk[i]), m.hourAt(walk[i + 1]), stroke);
    }
    final falls = Rules.fallsTo(play.base, clock);
    if (walk.length > 1 || falls != walk.last) {
      canvas.drawLine(
        m.hourAt(walk.last),
        m.hourAt(falls),
        Paint()
          ..color = play.comesHome ? Palette.home : Palette.stray
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 4 : 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
    // The hours.
    for (var h = 0; h < clock; h++) {
      final p = m.hourAt(h);
      final isTouched = touched.contains(h);
      canvas.drawCircle(p, bare ? 8 : 5.5, Paint()..color = isTouched ? Palette.touched : Palette.hourDim);
      if (h == 1 % clock) {
        canvas.drawCircle(p, bare ? 12 : 8.5, Paint()..color = Palette.home..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 2);
      }
      if (!bare) {
        final out = (p - m.centre) / (p - m.centre).distance;
        _word(canvas, '$h', p + out * 15, isTouched ? Palette.ink : Palette.inkDim, size, 11);
      }
    }
    if (bare || !m.roomy) return;
    final order = play.order;
    _word(
      canvas,
      order == null
          ? 'never home: ${falls == walk.last ? 'stops at' : 'falls back to'} $falls'
          : order == 1
              ? 'home before it starts'
              : 'home on step $order, ${walk.length} of ${Rules.phi(clock)} hours',
      Offset(size.width / 2, size.height - 11),
      order == null ? Palette.stray : Palette.home,
      size,
      12,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(RootView old) => old.play != play || old.bare != bare;
}
