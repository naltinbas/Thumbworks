import 'dart:math';

import 'package:flutter/material.dart';

import '../cut/play.dart';
import '../cut/rules.dart';
import 'palette.dart';

/// Where the field sits in a board of a given size: pegs on a square
/// grid, (0, 0) at the bottom left, y running up, the triangle's legs
/// along the bottom and the left.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    if (bare) {
      // The mark fits the triangle with a little room round it.
      final room = min(size.width, size.height) * 0.8;
      cell = room / Rules.leg;
      origin = Offset((size.width - room) / 2, (size.height + room) / 2);
    } else {
      final strip = roomy ? 26.0 : 0.0;
      final room = min(size.width - 40, size.height - strip - 28);
      cell = room / (Rules.side - 1);
      final left = (size.width - room) / 2, top = (size.height - strip - room) / 2;
      origin = Offset(left, top + room);
    }
  }

  final Play play;
  final Size size;
  late final double cell;

  /// Where peg (0, 0) falls; y counts upward from there.
  late final Offset origin;

  Offset at(double x, double y) => Offset(origin.dx + x * cell, origin.dy - y * cell);

  Offset pegAt(Peg p) => at(p.$1.toDouble(), p.$2.toDouble());

  Offset pointAt(Point p) => at(p.$1.toDouble, p.$2.toDouble);

  /// The peg under a point, or null when none is near enough.
  Peg? under(Offset p) {
    final x = ((p.dx - origin.dx) / cell).round(), y = ((origin.dy - p.dy) / cell).round();
    if (x < 0 || y < 0 || x >= Rules.side || y >= Rules.side) return null;
    return (pegAt((x, y)) - p).distance <= cell * 0.45 ? (x, y) : null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The field, the triangle, the line and its three cuts.
class CutView extends CustomPainter {
  const CutView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (peg, lift).
  final (Peg, bool)? pointing;

  final TextStyle labels;

  /// Whether to draw the triangle and the line only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (!bare) {
      for (final p in Rules.pegs) {
        canvas.drawCircle(m.pegAt(p), 2.2, Paint()..color = Palette.peg);
      }
    }
    final a = m.pegAt(Rules.a), b = m.pegAt(Rules.b), c = m.pegAt(Rules.c);
    // The side-lines faint beyond the sides, then the triangle.
    final faint = Paint()..color = Palette.chalkDim..strokeWidth = 1;
    final reach = size.width + size.height;
    for (final (u, v) in [(a, b), (b, c), (c, a)]) {
      final d = (v - u) / (v - u).distance;
      canvas.drawLine(u - d * reach, v + d * reach, faint);
    }
    canvas.drawPath(Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(c.dx, c.dy)..close(), Paint()..color = Palette.chalk..style = PaintingStyle.stroke..strokeWidth = bare ? 4 : 2..strokeJoin = StrokeJoin.round);
    // The line through the pegs set, right across the board.
    final chosen = play.chosen;
    if (chosen.length == 2) {
      final p = m.pegAt(chosen[0]), q = m.pegAt(chosen[1]);
      final d = (q - p) / (q - p).distance;
      canvas.drawLine(p - d * reach, q + d * reach, Paint()..color = Palette.cutter..strokeWidth = bare ? 4 : 2);
    }
    // The cuts.
    final crossings = play.crossings;
    if (crossings != null) {
      final ratios = play.ratios!;
      final cuts = [(crossings.$1, ratios.$1, 'F'), (crossings.$2, ratios.$2, 'D'), (crossings.$3, ratios.$3, 'E')];
      for (final (x, r, name) in cuts) {
        final at = m.pointAt(x);
        final inside = Rules.inside(r);
        canvas.drawCircle(at, bare ? 8 : 6, Paint()..color = inside ? Palette.inside : Palette.outside);
        if (!bare) _word(canvas, '$name ${Rules.tellPoint(x)}', at + const Offset(0, -14), inside ? Palette.inside : Palette.outside, size, 10, backed: true);
      }
    }
    // The pegs set, and the pointer.
    for (var i = 0; i < chosen.length; i++) {
      canvas.drawCircle(m.pegAt(chosen[i]), bare ? 8 : 6, Paint()..color = Palette.held);
    }
    final aim = pointing;
    if (aim != null && !bare) {
      canvas.drawCircle(m.pegAt(aim.$1), 12, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    // The corners' names last, so nothing covers them.
    if (!bare) {
      _word(canvas, 'A', a + const Offset(-10, 10), Palette.chalk, size, 12, backed: true);
      _word(canvas, 'B', b + const Offset(10, 10), Palette.chalk, size, 12, backed: true);
      _word(canvas, 'C', c + const Offset(-10, -10), Palette.chalk, size, 12, backed: true);
    }
    canvas.restore();
    if (bare || !m.roomy) return;
    final String words;
    if (crossings != null) {
      final r = play.ratios!;
      words = 'AF:FB ${r.$1}, BD:DC ${r.$2}, CE:EA ${r.$3}: product ${Rules.product(r)}';
    } else if (play.flaw != null) {
      words = 'no three cuts: ${play.flaw}';
    } else {
      words = 'pegs ${chosen.length} of 2';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), Palette.inkDim, size, 11);
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
  bool shouldRepaint(CutView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
