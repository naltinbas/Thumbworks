import 'dart:math';

import 'package:flutter/material.dart';

import '../square/play.dart';
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

  Offset hourAt(int h, [double r = 1]) {
    final a = 2 * pi * (h % play.clock) / play.clock;
    return centre + Offset(sin(a), -cos(a)) * radius * r;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The clock, its squares lit, the base and its opposite, and where
/// they land.
class SquareView extends CustomPainter {
  const SquareView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the clock and the squares only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final p = play.clock;
    final squares = play.squares;
    canvas.drawCircle(m.centre, m.radius, Paint()..color = Palette.face..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
    // The base and its opposite land on the same square: two chords in.
    final other = p - play.base;
    final landing = m.hourAt(play.square);
    for (final (b, colour) in [(other, Palette.opposite), (play.base, Palette.base)]) {
      canvas.drawLine(m.hourAt(b), landing, Paint()..color = colour..strokeWidth = bare ? 4 : 2.5..strokeCap = StrokeCap.round);
    }
    // The hours.
    for (var h = 0; h < p; h++) {
      final at = m.hourAt(h);
      final isSquare = squares.contains(h);
      canvas.drawCircle(at, bare ? 8 : 5.5, Paint()..color = isSquare ? Palette.square : Palette.hourDim);
      if (h == play.base) canvas.drawCircle(at, bare ? 12 : 9, Paint()..color = Palette.base..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 2);
      if (h == other && other != play.base) canvas.drawCircle(at, bare ? 12 : 9, Paint()..color = Palette.opposite..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
      if (h == play.square) canvas.drawCircle(at, bare ? 12 : 9, Paint()..color = Palette.landing..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 2);
      if (!bare) {
        final out = (at - m.centre) / (at - m.centre).distance;
        _word(canvas, '$h', at + out * 15, isSquare ? Palette.ink : Palette.inkDim, size, 11);
      }
    }
    if (bare || !m.roomy) return;
    _word(
      canvas,
      '${squares.length} squares lit of the ${p - 1} hours but 0; ${play.base} and $other square to ${play.square}',
      Offset(size.width / 2, size.height - 12),
      Palette.inkDim,
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
  bool shouldRepaint(SquareView old) => old.play != play || old.bare != bare;
}
