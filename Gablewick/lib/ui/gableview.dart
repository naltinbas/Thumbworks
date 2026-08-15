import 'dart:math';

import 'package:flutter/material.dart';

import '../gable/play.dart';
import 'palette.dart';

/// Where the gable sits in a board of a given size: units to pixels,
/// the third side along the floor.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 22.0 : 0.0;
    // The apex: with c the base from (0, 0) to (c, 0), b from the left
    // corner and a from the right.
    final a = play.a, b = play.b, c = play.c;
    if (play.closes) {
      apexX = (b * b + c * c - a * a) / (2 * c);
      apexY = sqrt(max(0, b * b - apexX * apexX));
    } else {
      apexX = 0;
      apexY = 0;
    }
    final left = min(0.0, apexX), right = max(c.toDouble(), apexX);
    final width = right - left, height = play.closes ? apexY : 0.0;
    scale = min((size.width - 48) / max(width, 1), (size.height - strip - 60) / max(height, 1)).clamp(4.0, 60.0);
    origin = Offset(size.width / 2 - (left + width / 2) * scale, (size.height - strip) / 2 + height * scale / 2);
  }

  final Play play;
  final Size size;
  late final double apexX, apexY, scale;
  late final Offset origin;

  /// A point in units to pixels, y up.
  Offset at(double x, double y) => origin + Offset(x * scale, -y * scale);

  Offset get leftCorner => at(0, 0);
  Offset get rightCorner => at(play.c.toDouble(), 0);
  Offset get apex => at(apexX, apexY);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The gable: the triangle to scale, its height, and its area.
class GableView extends CustomPainter {
  const GableView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the gable only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    if (!play.closes) {
      // Laid flat: the sides do not close.
      final y = size.height / 2;
      final total = play.a + play.b + play.c;
      final s = (size.width - 40) / total;
      var x = 20.0;
      for (final (side, colour) in [(play.b, Palette.oak), (play.a, Palette.oak), (play.c, Palette.flat)]) {
        canvas.drawLine(Offset(x, y), Offset(x + side * s, y), Paint()..color = colour..strokeWidth = 4);
        x += side * s + 4;
      }
      if (!bare && m.roomy) _word(canvas, 'the sides do not close: ${play.a} + ${play.b} is not more than ${play.c}', Offset(size.width / 2, y + 22), Palette.flat, size);
      return;
    }
    final path = Path()
      ..moveTo(m.leftCorner.dx, m.leftCorner.dy)
      ..lineTo(m.rightCorner.dx, m.rightCorner.dy)
      ..lineTo(m.apex.dx, m.apex.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = play.wholeArea != null ? Palette.wholeFace : Palette.oakFace);
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.oak
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 6 : 3
        ..strokeJoin = StrokeJoin.round,
    );
    // The height, chalk, from the apex to the floor line.
    final foot = m.at(m.apexX, 0);
    canvas.drawLine(m.apex, foot, Paint()..color = Palette.chalk.withValues(alpha: 0.6)..strokeWidth = bare ? 3 : 1.5);
    if (m.apexX < 0 || m.apexX > play.c) {
      // The foot lies beyond the base: extend the floor line faint.
      canvas.drawLine(foot, m.apexX < 0 ? m.leftCorner : m.rightCorner, Paint()..color = Palette.chalk.withValues(alpha: 0.3)..strokeWidth = 1);
    }
    if (bare || !m.roomy) return;
    // The sides told at their middles, and the area under.
    _word(canvas, '${play.c}', (m.leftCorner + m.rightCorner) / 2 + const Offset(0, 12), Palette.brass, size);
    _word(canvas, '${play.b}', (m.leftCorner + m.apex) / 2 + Offset(m.apexX >= 0 ? -12 : 12, 0), Palette.brass, size);
    _word(canvas, '${play.a}', (m.rightCorner + m.apex) / 2 + Offset(m.apexX <= play.c ? 12 : -12, 0), Palette.brass, size);
    final whole = play.wholeArea;
    final areaTold = whole != null ? 'area $whole, whole' : 'area ${play.area.toStringAsFixed(2)}, not whole: sixteen times its square is ${play.sixteenAreaSquared}';
    _word(canvas, areaTold, Offset(size.width / 2, size.height - 11), whole != null ? Palette.good : Palette.inkDim, size);
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
  bool shouldRepaint(GableView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
