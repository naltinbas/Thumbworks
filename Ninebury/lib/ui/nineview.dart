import 'dart:math';

import 'package:flutter/material.dart';

import '../nine/play.dart';
import '../nine/rules.dart';
import 'palette.dart';

/// Where the nine-hour dial sits in a board of a given size: nine at
/// the top, standing for nought, the hours running clockwise.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare ? 0.0 : (roomy ? 30.0 : 0.0);
    final tiles = bare ? 0.0 : 44.0;
    final side = min(size.width, size.height - strip - tiles);
    centre = Offset(size.width / 2, tiles + (size.height - strip - tiles) / 2);
    radius = side / 2 - (bare ? 8 : 26);
  }

  final Play play;
  final Size size;
  late final Offset centre;
  late final double radius;

  /// The angle of hour [h] (0 to 8, nought at the top), from the top,
  /// clockwise, in radians.
  double angleOf(int h) => 2 * pi * (h % 9) / 9;

  Offset hourAt(int h, [double r = 1]) {
    final a = angleOf(h);
    return centre + Offset(sin(a), -cos(a)) * radius * r;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The dial, the three digits walked round it, and the root.
class NineView extends CustomPainter {
  const NineView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the dial and the walk only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    // The three digits on tiles.
    if (!bare) {
      final w = min(40.0, (size.width - 40) / 3);
      for (var i = 0; i < 3; i++) {
        final r = Rect.fromCenter(center: Offset(size.width / 2 + (i - 1) * (w + 6), 22), width: w, height: 34);
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), Paint()..color = Palette.tile);
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), Paint()..color = [Palette.hundreds, Palette.tens, Palette.units][i]..style = PaintingStyle.stroke..strokeWidth = 1.2);
        _word(canvas, '${play.digits[i]}', r.center, Palette.ink, size, 18);
      }
    }
    // The face and its hours.
    canvas.drawCircle(m.centre, m.radius, Paint()..color = Palette.face..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
    for (var h = 0; h < 9; h++) {
      final p = m.hourAt(h);
      canvas.drawCircle(p, bare ? 6 : 4, Paint()..color = Palette.face);
      if (!bare) {
        final out = (p - m.centre) / (p - m.centre).distance;
        _word(canvas, '${h == 0 ? 9 : h}', p + out * 15, Palette.inkDim, size, 12);
      }
    }
    // The walk: each digit an arc, from where the last left off.
    var at = 0;
    const colours = [Palette.hundreds, Palette.tens, Palette.units];
    const rings = [0.86, 0.72, 0.58];
    for (var i = 0; i < 3; i++) {
      final d = play.digits[i];
      final r = m.radius * rings[i];
      final rect = Rect.fromCircle(center: m.centre, radius: r);
      final paint = Paint()..color = colours[i]..style = PaintingStyle.stroke..strokeWidth = bare ? 6 : 4..strokeCap = StrokeCap.round;
      if (d > 0) {
        canvas.drawArc(rect, m.angleOf(at) - pi / 2, 2 * pi * d / 9, false, paint);
      }
      final start = m.hourAt(at, rings[i]);
      canvas.drawCircle(start, bare ? 4 : 3, Paint()..color = colours[i]);
      if (!bare && d > 0) {
        // The digit halfway along its arc, just inside it.
        final a = m.angleOf(at) + pi * d / 9;
        final mid = m.centre + Offset(sin(a), -cos(a)) * (r - 13);
        _word(canvas, '$d', mid, colours[i], size, 11);
      }
      at = (at + d) % 9;
    }
    // The root: a hand to it, and the hour lit.
    final rootAt = m.hourAt(play.root % 9);
    canvas.drawLine(m.centre, rootAt, Paint()..color = Palette.root..strokeWidth = bare ? 3 : 2);
    canvas.drawCircle(rootAt, bare ? 9 : 6.5, Paint()..color = Palette.root);
    canvas.drawCircle(m.centre, bare ? 5 : 3.5, Paint()..color = Palette.root);
    if (bare || !m.roomy) return;
    final (nines, over) = Rules.cast(play.number);
    _word(
      canvas,
      play.number == 0 ? 'nought: no nines to cast' : '${Rules.told(play.number)}; $nines nine${nines == 1 ? '' : 's'} and $over over',
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
  bool shouldRepaint(NineView old) => old.play != play || old.bare != bare;
}
