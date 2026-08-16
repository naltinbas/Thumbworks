import 'dart:math';

import 'package:flutter/material.dart';

import '../line/play.dart';
import '../line/rules.dart';
import 'palette.dart';

/// Where the field sits in a board of a given size: pegs on a square
/// grid, (0, 0) at the bottom left, y running up.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    if (bare) {
      // The mark fits the triangle and its centres, not the whole field.
      final xs = <double>[], ys = <double>[];
      for (final p in play.pegs) {
        xs.add(p.$1.toDouble());
        ys.add(p.$2.toDouble());
      }
      for (final c in [play.centroid, play.circumcentre, play.orthocentre]) {
        xs.add(c.$1.toDouble);
        ys.add(c.$2.toDouble);
      }
      final x0 = xs.reduce(min), x1 = xs.reduce(max), y0 = ys.reduce(min), y1 = ys.reduce(max);
      cell = min(size.width / (x1 - x0 + 1.2), size.height / (y1 - y0 + 1.2));
      origin = Offset(size.width / 2 - (x0 + x1) / 2 * cell, size.height / 2 + (y0 + y1) / 2 * cell);
    } else {
      // Room for the letters beside the outer pegs, and a strip at the
      // foot for the words.
      final strip = roomy ? 26.0 : 0.0;
      final room = min(size.width - 56, size.height - strip - 28);
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

  Offset centreAt(Centre c) => at(c.$1.toDouble, c.$2.toDouble);

  /// The peg under a point, or null when none is near enough.
  Peg? under(Offset p) {
    final x = ((p.dx - origin.dx) / cell).round(), y = ((origin.dy - p.dy) / cell).round();
    if (x < 0 || y < 0 || x >= Rules.side || y >= Rules.side) return null;
    return (pegAt((x, y)) - p).distance <= cell * 0.45 ? (x, y) : null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The field, the triangle, its three centres and the line through them.
class LineView extends CustomPainter {
  const LineView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (peg, where to set it).
  final (int, Peg)? pointing;

  final TextStyle labels;

  /// Whether to draw the triangle and its centres only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (!bare) {
      for (final p in Rules.pegs) {
        canvas.drawCircle(m.pegAt(p), 2.5, Paint()..color = Palette.peg);
      }
    }
    final a = m.pegAt(play.a), b = m.pegAt(play.b), c = m.pegAt(play.c);
    final g = m.centreAt(play.centroid), o = m.centreAt(play.circumcentre), h = m.centreAt(play.orthocentre);
    // The circle through the corners, faint.
    canvas.drawCircle(o, (a - o).distance, Paint()..color = Palette.circle..style = PaintingStyle.stroke..strokeWidth = bare ? 2 : 1.2);
    // The triangle.
    final tri = Paint()..color = Palette.chalk..style = PaintingStyle.stroke..strokeWidth = bare ? 4 : 2..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(c.dx, c.dy)..close(), tri);
    // The Euler line, through O and H and on to the edge of the board.
    final dir = h - o;
    if (dir.distance > 1e-9) {
      final u = dir / dir.distance;
      final reach = size.width + size.height;
      _dashed(canvas, o - u * reach, o + u * reach, Paint()..color = Palette.euler..strokeWidth = bare ? 3 : 1.6);
    }
    // The centres.
    final r = bare ? 9.0 : 5.5;
    canvas.drawCircle(o, r, Paint()..color = Palette.circum);
    canvas.drawCircle(h, r, Paint()..color = Palette.ortho);
    canvas.drawCircle(g, r, Paint()..color = Palette.centroid);
    // The pegs, held or not, and the pointer.
    for (var i = 0; i < 3; i++) {
      final p = m.pegAt(play.pegs[i]);
      final isHeld = play.held == i;
      canvas.drawCircle(p, bare ? 7 : 6, Paint()..color = isHeld ? Palette.held : Palette.chalk);
      if (isHeld) canvas.drawCircle(p, 11, Paint()..color = Palette.held..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    final aim = pointing;
    if (aim != null && !bare) {
      final from = m.pegAt(play.pegs[aim.$1]), to = m.pegAt(aim.$2);
      final shown = Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5;
      canvas.drawCircle(from, 12, shown);
      canvas.drawCircle(to, 12, shown);
      _dashed(canvas, from, to, Paint()..color = Palette.shown..strokeWidth = 1.5);
    }
    if (!bare) {
      for (var i = 0; i < 3; i++) {
        final p = m.pegAt(play.pegs[i]);
        final away = _awayFrom(p, [a, b, c]);
        _word(canvas, Play.names[i], p + away * 13, Palette.chalk, size, 12);
      }
      _word(canvas, 'G', g + const Offset(0, -12), Palette.centroid, size, 11);
      _word(canvas, 'O', o + const Offset(0, 12), Palette.circum, size, 11);
      _word(canvas, 'H', h + const Offset(0, 12), Palette.ortho, size, 11);
    }
    canvas.restore();
    if (bare || !m.roomy) return;
    _word(
      canvas,
      'G ${Rules.told(play.centroid)}  O ${Rules.told(play.circumcentre)}  H ${Rules.told(play.orthocentre)}',
      Offset(size.width / 2, size.height - 11),
      Palette.inkDim,
      size,
      11,
    );
  }

  /// The way out from a corner, away from the other two.
  Offset _awayFrom(Offset p, List<Offset> corners) {
    var sum = Offset.zero;
    for (final q in corners) {
      if (q != p) sum += (p - q) / max(1e-9, (p - q).distance);
    }
    return sum.distance < 1e-9 ? const Offset(0, -1) : sum / sum.distance;
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final total = (to - from).distance;
    if (total < 1e-9) return;
    final u = (to - from) / total;
    for (var d = 0.0; d < total; d += 10) {
      canvas.drawLine(from + u * d, from + u * min(d + 5, total), paint);
    }
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
  bool shouldRepaint(LineView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
