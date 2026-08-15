import 'dart:math';

import 'package:flutter/material.dart';

import '../star/play.dart';
import 'palette.dart';

/// Where the hoop and its nails sit in a board of a given size.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 26.0 : 0.0;
    centre = Offset(size.width / 2, (size.height - strip) / 2);
    radius = min(size.width, size.height - strip) / 2 - (roomy ? 22 : 10);
  }

  final Play play;
  final Size size;
  late final Offset centre;
  late final double radius;

  /// Nail [i] of the ring, nail 0 at the top, the rest clockwise.
  Offset nail(int i) {
    final a = 2 * pi * i / play.nails;
    return centre + Offset(sin(a), -cos(a)) * radius;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The hoop, the nails and the strokes of thread.
class StarView extends CustomPainter {
  const StarView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the hoop and the thread only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawCircle(
      m.centre,
      m.radius,
      Paint()
        ..color = Palette.hoop
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 6 : 3,
    );
    // The strokes, the first in red and the rest each in its own colour;
    // a stroke of two is a bare line, and the rim is drawn thin.
    final strokes = play.strokes;
    for (var s = 0; s < strokes.length; s++) {
      final stroke = strokes[s];
      final colour = play.isStar ? Palette.threads[s % Palette.threads.length] : Palette.rim;
      final paint = Paint()
        ..color = s == 0 ? colour : colour.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 5 : (s == 0 ? 2.5 : 1.8)
        ..strokeJoin = StrokeJoin.round;
      final path = Path()..moveTo(m.nail(stroke[0]).dx, m.nail(stroke[0]).dy);
      for (var i = 1; i <= stroke.length; i++) {
        final p = m.nail(stroke[i % stroke.length]);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
    // The nails, numbered along the first stroke when there is room.
    for (var i = 0; i < play.nails; i++) {
      canvas.drawCircle(m.nail(i), bare ? 9 : 5, Paint()..color = Palette.nailDark);
      canvas.drawCircle(m.nail(i), bare ? 6 : 3.5, Paint()..color = Palette.nail);
    }
    if (bare || !m.roomy) return;
    final first = strokes[0];
    for (var i = 0; i < first.length; i++) {
      final at = m.nail(first[i]);
      final out = (at - m.centre) / (at - m.centre).distance;
      _word(canvas, '${i + 1}', at + out * 13, Palette.threads[0], size);
    }
    final String caption;
    if (!play.isStar) {
      caption = 'skip ${play.skip}: the rim, no star';
    } else if (strokes.length == 1) {
      caption = 'one stroke, all ${play.nails} nails';
    } else {
      caption = '${strokes.length} strokes of ${strokes[0].length} nails';
    }
    _word(canvas, caption, Offset(size.width / 2, size.height - 12), Palette.inkDim, size);
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
  bool shouldRepaint(StarView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
