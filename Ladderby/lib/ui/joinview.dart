import 'dart:math';

import 'package:flutter/material.dart';

import '../join/play.dart';
import '../join/rules.dart';
import 'palette.dart';

/// Where the rails sit in a board of a given size: the bottom rail at
/// height 0, the top rail at height 6, pegs 0 to 7 along each, and a
/// pegged field from three below the bottom rail to three above the
/// top, where crossings may fall.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    if (bare) {
      // The mark fits the rails, half a peg's room at either end and a
      // little above and below.
      final room = min(size.width, size.height);
      cell = room / 8;
      rise = cell;
      origin = Offset((size.width - room) / 2 + cell / 2, (size.height - room) / 2 + 7 * cell);
    } else {
      final strip = roomy ? 26.0 : 0.0;
      cell = min((size.width - 40) / Rules.last, 48.0);
      rise = (size.height - strip - 12) / (top - bottom);
      origin = Offset((size.width - Rules.last * cell) / 2, 6 + top * rise);
    }
  }

  /// The field's reach, in heights: three below the bottom rail to
  /// three above the top.
  static const bottom = -3, top = 9;

  final Play play;
  final Size size;

  /// A peg's room along a rail, and a height's room up the board.
  late final double cell, rise;

  /// Where (0, 0) falls; heights count upward from there.
  late final Offset origin;

  Offset at(double x, double y) => Offset(origin.dx + x * cell, origin.dy - y * rise);

  Offset pegAt(Peg p) => at(p.$2.toDouble(), p.$1 == 0 ? 0 : Rules.height.toDouble());

  Offset pointAt(Point p) => at(p.$1.toDouble, p.$2.toDouble);

  /// The peg under a point, or null when none is near enough.
  Peg? under(Offset p) {
    final x = ((p.dx - origin.dx) / cell).round();
    if (x < 0 || x > Rules.last) return null;
    for (final rail in [0, 1]) {
      final d = pegAt((rail, x)) - p;
      if (d.dx.abs() <= cell * 0.5 && d.dy.abs() <= max(16.0, rise)) return (rail, x);
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The field, the rails, the pegs picked, the six cross-joins, their
/// three crossings and the line through them.
class JoinView extends CustomPainter {
  const JoinView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (peg, lift).
  final (Peg, bool)? pointing;

  final TextStyle labels;

  /// Whether to draw the rails and the hexagon only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final reach = size.width + size.height;
    if (!bare) {
      // The field's pegs, where crossings may fall.
      for (var y = Metrics.bottom; y <= Metrics.top; y++) {
        for (var x = 0; x <= Rules.last; x++) {
          canvas.drawCircle(m.at(x.toDouble(), y.toDouble()), 1.8, Paint()..color = Palette.peg);
        }
      }
      // The middle rung, faint.
      final mid = m.at(0, 3);
      canvas.drawLine(Offset(mid.dx - m.cell / 2, mid.dy), Offset(m.at(Rules.last.toDouble(), 3).dx + m.cell / 2, mid.dy), Paint()..color = Palette.line..strokeWidth = 1);
    }
    // The mark's strokes grow with it; the board's stay thin.
    final thick = bare ? m.cell * 0.09 : 2.0;
    // The rails and their pegs.
    for (final rail in [0, 1]) {
      final l = m.pegAt((rail, 0)), r = m.pegAt((rail, Rules.last));
      canvas.drawLine(l - Offset(m.cell / 2, 0), r + Offset(m.cell / 2, 0), Paint()..color = Palette.chalk..strokeWidth = bare ? m.cell * 0.12 : 2);
      if (!bare) {
        for (var x = 0; x <= Rules.last; x++) {
          canvas.drawCircle(m.pegAt((rail, x)), 4, Paint()..color = Palette.chalkDim);
        }
      }
    }
    // The six cross-joins, those whose pegs are picked: solid between
    // the rails, faint beyond; the mark's run a little past the rails.
    final bottom = play.bottom, top = play.top;
    for (var i = 0; i < bottom.length; i++) {
      for (var j = 0; j < top.length; j++) {
        if (i == j) continue;
        final p = m.pegAt((0, bottom[i])), q = m.pegAt((1, top[j]));
        final d = (q - p) / (q - p).distance;
        if (bare) {
          canvas.drawLine(p - d * m.cell * 0.7, q + d * m.cell * 0.7, Paint()..color = Palette.join..strokeWidth = thick..strokeCap = StrokeCap.round);
        } else {
          canvas.drawLine(p - d * reach, q + d * reach, Paint()..color = Palette.joinDim..strokeWidth = 1);
          canvas.drawLine(p, q, Paint()..color = Palette.join..strokeWidth = thick);
        }
      }
    }
    // The crossings, and the line through them.
    final crossings = play.crossings;
    if (crossings != null) {
      final (x, y, z) = crossings;
      final px = m.pointAt(x), pz = m.pointAt(z);
      final d = (pz - px) / (pz - px).distance;
      _dashed(canvas, px - d * reach, pz + d * reach, Paint()..color = Palette.gold..strokeWidth = bare ? m.cell * 0.08 : 1.5, dash: bare ? m.cell * 0.28 : 6);
      // The names sit off the line, on alternate sides, so close
      // crossings do not cover each other's.
      final off = Offset(-d.dy, d.dx) * 13;
      for (final (p, name, side) in [(x, 'X', 1.0), (y, 'Y', -1.0), (z, 'Z', 1.0)]) {
        final at = m.pointAt(p);
        canvas.drawCircle(at, bare ? m.cell * 0.2 : 6, Paint()..color = Palette.gold);
        if (!bare) _word(canvas, name, at + off * side, Palette.gold, size, 11, backed: true);
      }
    }
    // The pegs picked and their names, and the pointer.
    for (var i = 0; i < bottom.length; i++) {
      final at = m.pegAt((0, bottom[i]));
      canvas.drawCircle(at, bare ? m.cell * 0.18 : 6, Paint()..color = Palette.held);
      if (!bare) _word(canvas, Play.bottomNames[i], at + const Offset(0, 14), Palette.held, size, 12, backed: true);
    }
    for (var i = 0; i < top.length; i++) {
      final at = m.pegAt((1, top[i]));
      canvas.drawCircle(at, bare ? m.cell * 0.18 : 6, Paint()..color = Palette.held);
      if (!bare) _word(canvas, Play.topNames[i], at + const Offset(0, -14), Palette.held, size, 12, backed: true);
    }
    final aim = pointing;
    if (aim != null && !bare) {
      canvas.drawCircle(m.pegAt(aim.$1), 12, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    canvas.restore();
    if (bare || !m.roomy) return;
    final String words;
    if (crossings != null) {
      words = 'X ${Rules.tell(crossings.$1)}  Y ${Rules.tell(crossings.$2)}  Z ${Rules.tell(crossings.$3)}';
    } else if (play.parallel != null) {
      words = 'no crossing: ${play.parallel} run parallel';
    } else {
      words = 'bottom ${bottom.length} of 3, top ${top.length} of 3';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), crossings != null ? Palette.gold : Palette.inkDim, size, 11, backed: true);
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint, {required double dash}) {
    final d = to - from;
    final length = d.distance;
    final unit = d / length;
    var run = 0.0;
    while (run < length) {
      final end = min(run + dash, length);
      canvas.drawLine(from + unit * run, from + unit * end, paint);
      run += dash * 1.8;
    }
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
  bool shouldRepaint(JoinView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
