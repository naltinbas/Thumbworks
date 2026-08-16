import 'dart:math';

import 'package:flutter/material.dart';

import '../sliver/play.dart';
import '../sliver/rules.dart';
import 'palette.dart';

/// Where the field sits in a board of a given size: A at the bottom
/// left, B at the bottom right, C at the top left, the sides marked off
/// in twelfths.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    final room = min(size.width - (bare ? 8 : 30), size.height - strip - (bare ? 8 : 24));
    cell = room / Rules.side;
    final left = (size.width - room) / 2, top = (size.height - strip - room) / 2;
    origin = Offset(left, top + room);
  }

  final Play play;
  final Size size;
  late final double cell;

  /// Where the corner A falls; the field runs right and up from there.
  late final Offset origin;

  Offset at(double x, double y) => Offset(origin.dx + x * cell, origin.dy - y * cell);

  Offset spotAt(Spot p) => at(p.$1.toDouble, p.$2.toDouble);

  Offset cornerAt((int, int) p) => at(p.$1.toDouble(), p.$2.toDouble());

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The field, the three cuts, the marks and the sliver between them.
class SliverView extends CustomPainter {
  const SliverView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (which mark, by).
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the field, the cuts and the sliver only, for the
  /// mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final thick = bare ? m.cell * 0.1 : 2.0;
    final a = m.cornerAt(Rules.a), b = m.cornerAt(Rules.b), c = m.cornerAt(Rules.c);
    final field = Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(c.dx, c.dy)..close();
    canvas.drawPath(field, Paint()..color = Palette.field);
    canvas.drawPath(field, Paint()..color = Palette.chalk..style = PaintingStyle.stroke..strokeWidth = thick..strokeJoin = StrokeJoin.round);
    // The twelfths along each side.
    if (!bare) {
      for (var k = 1; k < Rules.side; k++) {
        for (final p in [Rules.onBC(k), Rules.onCA(k), Rules.onAB(k)]) {
          canvas.drawCircle(m.spotAt(p), 1.8, Paint()..color = Palette.line);
        }
      }
    }
    // The three cuts, corner to mark.
    final marks = [Rules.onBC(play.marks[0]), Rules.onCA(play.marks[1]), Rules.onAB(play.marks[2])];
    final corners = [Rules.spotOf(Rules.a), Rules.spotOf(Rules.b), Rules.spotOf(Rules.c)];
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(m.spotAt(corners[i]), m.spotAt(marks[i]), Paint()..color = Palette.copper..strokeWidth = thick..strokeCap = StrokeCap.round);
    }
    // The sliver.
    final sliver = play.sliver;
    if (sliver != null) {
      final p = sliver.map(m.spotAt).toList();
      final path = Path()..moveTo(p[0].dx, p[0].dy)..lineTo(p[1].dx, p[1].dy)..lineTo(p[2].dx, p[2].dy)..close();
      canvas.drawPath(path, Paint()..color = Palette.goldFill);
      canvas.drawPath(path, Paint()..color = Palette.gold..style = PaintingStyle.stroke..strokeWidth = thick * 0.8..strokeJoin = StrokeJoin.round);
      if (play.gone) {
        canvas.drawCircle(p[0], bare ? m.cell * 0.3 : 5, Paint()..color = Palette.gold);
      }
    }
    // The marks, named, and the corners.
    for (var i = 0; i < 3; i++) {
      final at = m.spotAt(marks[i]);
      canvas.drawCircle(at, bare ? m.cell * 0.22 : 5, Paint()..color = Palette.held);
      if (!bare) _word(canvas, Play.names[i], at + Offset(i == 1 ? 12 : 0, i == 1 ? 0 : (i == 2 ? 12 : -12)), Palette.held, size, 11, backed: true);
    }
    if (!bare) {
      _word(canvas, 'A', a + const Offset(-9, 9), Palette.chalk, size, 12, backed: true);
      _word(canvas, 'B', b + const Offset(9, 9), Palette.chalk, size, 12, backed: true);
      _word(canvas, 'C', c + const Offset(-9, -9), Palette.chalk, size, 12, backed: true);
    }
    final aim = pointing;
    if (aim != null && !bare) {
      canvas.drawCircle(m.spotAt(marks[aim.$1]), 11, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    if (bare || !m.roomy) return;
    final share = play.share;
    final words = play.gone
        ? 'the cuts meet: no sliver at all'
        : 'the sliver takes ${Rules.tellShare(share)} of the field';
    _word(canvas, words, Offset(size.width / 2, size.height - 11), Palette.gold, size, 12, backed: true);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool backed = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize))),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    if (backed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 2, y - 1, text.width + 4, text.height + 2), const Radius.circular(3)),
        Paint()..color = Palette.night,
      );
    }
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(SliverView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
