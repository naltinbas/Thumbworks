import 'dart:math';

import 'package:flutter/material.dart';

import '../foot/play.dart';
import '../foot/rules.dart';
import 'palette.dart';

/// Where the field sits in a board of a given size: pegs from (-5, -5)
/// to (5, 5) about the middle, the circle of radius five through the
/// twelve rim pegs.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    final room = min(size.width - (bare ? 0 : 16), size.height - strip - (bare ? 0 : 8));
    cell = room / (bare ? 11.5 : 12);
    centre = Offset(size.width / 2, (size.height - strip) / 2);
  }

  final Play play;
  final Size size;
  late final double cell;
  late final Offset centre;

  Offset at(double x, double y) => Offset(centre.dx + x * cell, centre.dy - y * cell);

  Offset pegAt(Peg p) => at(p.$1.toDouble(), p.$2.toDouble());

  Offset pointAt(Point p) => at(p.$1.toDouble, p.$2.toDouble);

  /// The peg under a point, or null when none is near enough.
  Peg? under(Offset p) {
    final x = ((p.dx - centre.dx) / cell).round(), y = ((centre.dy - p.dy) / cell).round();
    if (!Rules.inField((x, y))) return null;
    return (pegAt((x, y)) - p).distance <= cell * 0.45 ? (x, y) : null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The field, the circle, the triangle, the point, its feet and their
/// line or triangle.
class FootView extends CustomPainter {
  const FootView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (peg, lift).
  final (Peg, bool)? pointing;

  final TextStyle labels;

  /// Whether to draw the circle, the triangle and the feet only, for
  /// the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final thick = bare ? m.cell * 0.09 : 2.0;
    if (!bare) {
      for (final p in Rules.field) {
        canvas.drawCircle(m.pegAt(p), Rules.onRim(p) ? 3.5 : 2.0, Paint()..color = Rules.onRim(p) ? Palette.rimPeg : Palette.peg);
      }
    }
    canvas.drawCircle(m.centre, Rules.radius * m.cell, Paint()..color = Palette.chalkDim..style = PaintingStyle.stroke..strokeWidth = bare ? thick * 0.8 : 1.5);
    final corners = play.corners;
    // The side-lines faint beyond the sides, then the triangle.
    final reach = size.width + size.height;
    if (corners.length >= 2) {
      final n = corners.length;
      for (var i = 0; i < (n == 3 ? 3 : n - 1); i++) {
        final u = m.pegAt(corners[i]), v = m.pegAt(corners[(i + 1) % n]);
        final d = (v - u) / (v - u).distance;
        if (!bare) canvas.drawLine(u - d * reach, v + d * reach, Paint()..color = Palette.line..strokeWidth = 1);
        canvas.drawLine(u, v, Paint()..color = Palette.chalk..strokeWidth = thick..strokeCap = StrokeCap.round);
      }
    }
    // The point, its feet, the drops, and the feet's line or triangle.
    final feet = play.feet;
    final point = play.point;
    if (feet != null && point != null) {
      final f = feet.map(m.pointAt).toList();
      final line = play.line;
      if (line != null) {
        final a = m.pointAt(line.$1), b = m.pointAt(line.$2);
        final d = (b - a) / (b - a).distance;
        _dashed(canvas, a - d * reach, b + d * reach, Paint()..color = Palette.gold..strokeWidth = bare ? thick : 1.5, dash: bare ? m.cell * 0.3 : 6);
      } else {
        canvas.drawPath(Path()..moveTo(f[0].dx, f[0].dy)..lineTo(f[1].dx, f[1].dy)..lineTo(f[2].dx, f[2].dy)..close(), Paint()..color = Palette.goldFill);
        canvas.drawPath(Path()..moveTo(f[0].dx, f[0].dy)..lineTo(f[1].dx, f[1].dy)..lineTo(f[2].dx, f[2].dy)..close(), Paint()..color = Palette.gold..style = PaintingStyle.stroke..strokeWidth = thick * 0.8);
      }
      for (final foot in f) {
        _dashed(canvas, m.pegAt(point), foot, Paint()..color = Palette.copper..strokeWidth = bare ? thick * 0.7 : 1.2, dash: bare ? m.cell * 0.2 : 4);
        canvas.drawCircle(foot, bare ? m.cell * 0.14 : 4.5, Paint()..color = Palette.gold);
      }
    }
    // The pegs set, named, and the pointer.
    for (var i = 0; i < play.pegs.length; i++) {
      final at = m.pegAt(play.pegs[i]);
      final isPoint = i == 3;
      canvas.drawCircle(at, bare ? m.cell * (isPoint ? 0.18 : 0.14) : (isPoint ? 7 : 6), Paint()..color = isPoint ? Palette.gold : Palette.held);
      if (!bare) _word(canvas, Play.names[i], at + const Offset(0, -13), isPoint ? Palette.gold : Palette.held, size, 11, backed: true);
    }
    final aim = pointing;
    if (aim != null && !bare) {
      canvas.drawCircle(m.pegAt(aim.$1), 12, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    canvas.restore();
    if (bare || !m.roomy) return;
    final String words;
    if (feet == null) {
      words = play.pegs.length < 3 ? 'corners ${play.pegs.length} of 3, on the rim' : 'three corners set: now the point, anywhere';
    } else if (play.line != null) {
      words = 'the feet in a line';
    } else {
      final r = play.ratio!;
      words = 'the feet\'s triangle ${r.n.isNegative ? 'minus ' : ''}${r.n.abs()}/${r.d} of the whole, turned ${r.n.isNegative ? 'the other way' : 'the same way'}';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), feet != null ? Palette.gold : Palette.inkDim, size, 12, backed: true);
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint, {required double dash}) {
    final d = to - from;
    final length = d.distance;
    if (length == 0) return;
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
  bool shouldRepaint(FootView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
