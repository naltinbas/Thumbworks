import 'dart:math';

import 'package:flutter/material.dart';

import '../drum/play.dart';
import 'palette.dart';

/// Where the ring sits in a board of a given size.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 22.0 : 0.0;
    centre = Offset(size.width / 2, (size.height - strip) / 2);
    radius = min(size.width, size.height - strip) / 2 - (roomy ? 34 : 12);
  }

  final Play play;
  final Size size;
  late final Offset centre;
  late final double radius;

  /// Step [i] of the ring, step 0 at the top, the rest clockwise.
  Offset step(int i) {
    final a = 2 * pi * i / play.level.steps;
    return centre + Offset(sin(a), -cos(a)) * radius;
  }

  /// The step under a point, or null: the nearest, within reach.
  int? under(Offset p) {
    for (var i = 0; i < play.level.steps; i++) {
      if ((step(i) - p).distance <= max(14, radius * 0.16)) return i;
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The ring, the hits and rests, and the gaps.
class DrumView extends CustomPainter {
  const DrumView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the ring only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.level.steps;
    canvas.drawCircle(
      m.centre,
      m.radius,
      Paint()
        ..color = Palette.ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 5 : 2,
    );
    // The gaps, as arcs between hits, alternating tint.
    final hits = play.hitsAt;
    if (hits.length >= 2) {
      for (var i = 0; i < hits.length; i++) {
        final a = hits[i], b = hits[(i + 1) % hits.length];
        final start = 2 * pi * a / n - pi / 2;
        var sweep = 2 * pi * ((b - a + n) % n) / n;
        if (sweep == 0) sweep = 2 * pi;
        canvas.drawArc(
          Rect.fromCircle(center: m.centre, radius: m.radius),
          start,
          sweep,
          false,
          Paint()
            ..color = i.isEven ? Palette.gapArc : Palette.gapArcOdd
            ..style = PaintingStyle.stroke
            ..strokeWidth = bare ? 8 : 4,
        );
      }
    }
    final r = bare ? m.radius * 0.11 : max(7.0, m.radius * 0.07);
    for (var i = 0; i < n; i++) {
      final p = m.step(i);
      final hit = hits.contains(i);
      canvas.drawCircle(p, hit ? r * 1.6 : r, Paint()..color = hit ? Palette.hit : Palette.rest);
      canvas.drawCircle(
        p,
        hit ? r * 1.6 : r,
        Paint()
          ..color = hit ? Palette.hitRim : Palette.restRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : 1.5,
      );
    }
    if (bare) return;
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        m.step(aim.$2),
        r * 2.6,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (!m.roomy) return;
    // The step numbers outside the ring, and the gaps at the arcs' middles.
    for (var i = 0; i < n; i++) {
      final p = m.step(i);
      final out = (p - m.centre) / (p - m.centre).distance;
      _word(canvas, '${i + 1}', p + out * (r * 1.6 + 11), Palette.inkDim, size);
    }
    if (hits.length >= 2) {
      final gaps = play.gaps;
      for (var i = 0; i < hits.length; i++) {
        final a = hits[i];
        final mid = 2 * pi * (a + gaps[i] / 2) / n;
        final p = m.centre + Offset(sin(mid), -cos(mid)) * (m.radius - 18);
        _word(canvas, '${gaps[i]}', p, Palette.chalk, size);
      }
    }
    final told = hits.isEmpty ? 'no hits yet' : play.hitsAt.length == 1 ? 'one hit' : 'gaps ${play.gaps.join(', ')}${play.isEven ? ', even' : ', not even'}${play.hasEqualGaps ? ', all alike' : ''}';
    _word(canvas, told, Offset(size.width / 2, size.height - 11), Palette.inkDim, size);
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
  bool shouldRepaint(DrumView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
