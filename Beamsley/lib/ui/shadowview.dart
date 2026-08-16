import 'dart:math';

import 'package:flutter/material.dart';

import '../shadow/play.dart';
import '../shadow/rules.dart';
import 'palette.dart';

/// Where the field sits in a board of a given size: the lantern in the
/// middle, pegs from -2 to 2 about it, and room out to seven each way
/// so that the shadows and most of the meetings show.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    final room = min(size.width - (bare ? 0 : 12), size.height - strip - (bare ? 0 : 8));
    if (bare) {
      // The mark fits what it draws: the lantern, the pegs, the shadows
      // and the meetings that stand somewhere.
      final xs = <double>[0], ys = <double>[0];
      for (final p in [...play.pegs, ...play.shadows]) {
        xs.add(p.$1.toDouble());
        ys.add(p.$2.toDouble());
      }
      for (final h in play.meetings ?? const <Homo>[]) {
        if (h.$3 != 0) {
          xs.add(h.$1 / h.$3);
          ys.add(h.$2 / h.$3);
        }
      }
      final left = xs.reduce(min), right = xs.reduce(max);
      final low = ys.reduce(min), high2 = ys.reduce(max);
      final wide = max(right - left, high2 - low) + 1.2;
      cell = room / wide;
      centre = Offset(size.width / 2 - (left + right) / 2 * cell, size.height / 2 + (low + high2) / 2 * cell);
      return;
    }
    cell = room / (2 * extent);
    centre = Offset(size.width / 2, (size.height - strip) / 2);
  }

  /// How far out the board reaches, in peg steps.
  static const extent = 7;

  final Play play;
  final Size size;
  late final double cell;
  late final Offset centre;

  Offset at(double x, double y) => Offset(centre.dx + x * cell, centre.dy - y * cell);

  Offset pegAt(Peg p) => at(p.$1.toDouble(), p.$2.toDouble());

  /// Where a homogeneous point falls, or null when it lies at infinity.
  Offset? pointAt(Homo h) => h.$3 == 0 ? null : at(h.$1 / h.$3, h.$2 / h.$3);

  /// The peg under a point, or null when none is near enough.
  Peg? under(Offset p) {
    final x = ((p.dx - centre.dx) / cell).round(), y = ((centre.dy - p.dy) / cell).round();
    if (!Rules.onField((x, y))) return null;
    return (pegAt((x, y)) - p).distance <= cell * 0.5 ? (x, y) : null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The lantern, the pegs, the triangle and its shadow, the meetings and
/// the axis.
class ShadowView extends CustomPainter {
  const ShadowView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: ('peg', i), ('lift', i) or
  /// ('cast', i).
  final (String, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the triangles and the axis only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final reach = size.width + size.height;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final thick = bare ? m.cell * 0.16 : 2.0;
    if (!bare) {
      for (final p in Rules.pegs) {
        canvas.drawCircle(m.pegAt(p), 2.6, Paint()..color = Palette.peg);
      }
    }
    final pegs = play.pegs, shadows = play.shadows;
    // The rays from the lantern, out past the shadows.
    for (var i = 0; i < pegs.length; i++) {
      final d = m.pegAt(pegs[i]) - m.centre;
      final unit = d / d.distance;
      canvas.drawLine(m.centre - unit * reach, m.centre + unit * reach, Paint()..color = Palette.ray..strokeWidth = 1);
    }
    // The triangle and its shadow, side by side.
    void drawSides(List<Peg> corners, Color colour, double width) {
      if (corners.length < 2) return;
      for (var i = 0; i < corners.length; i++) {
        if (corners.length < 3 && i == corners.length - 1) break;
        final u = m.pegAt(corners[i]), v = m.pegAt(corners[(i + 1) % corners.length]);
        canvas.drawLine(u, v, Paint()..color = colour..strokeWidth = width..strokeCap = StrokeCap.round);
      }
    }

    drawSides(shadows, Palette.copper, thick);
    drawSides(pegs, Palette.chalk, thick);
    // The axis, and the meetings that stand somewhere.
    final meetings = play.meetings;
    if (meetings != null) {
      final axis = play.axis;
      if (axis != null && !(axis.$1 == 0 && axis.$2 == 0)) {
        // Two points of the axis in peg steps, far enough apart to cross
        // the board, then brought to the board so that the turn of the
        // picture takes them with it.
        final along = Offset(-axis.$2.toDouble(), axis.$1.toDouble());
        final unit = along / along.distance;
        final on = axis.$1 != 0
            ? Offset(-axis.$3 / axis.$1, 0)
            : Offset(0, -axis.$3 / axis.$2);
        const far = 4.0 * Metrics.extent;
        final head = on - unit * far, tail = on + unit * far;
        _dashed(canvas, m.at(head.dx, head.dy), m.at(tail.dx, tail.dy), Paint()..color = Palette.gold..strokeWidth = bare ? thick * 0.7 : 1.6, dash: bare ? m.cell * 0.4 : 7);
      }
      for (final h in meetings) {
        final at = m.pointAt(h);
        if (at != null) canvas.drawCircle(at, bare ? m.cell * 0.24 : 5, Paint()..color = Palette.gold);
      }
    }
    // The pegs set and their shadows, named.
    for (var i = 0; i < pegs.length; i++) {
      final at = m.pegAt(pegs[i]), shade = m.pegAt(shadows[i]);
      canvas.drawCircle(shade, bare ? m.cell * 0.2 : 5, Paint()..color = Palette.copper);
      canvas.drawCircle(at, bare ? m.cell * 0.24 : 6, Paint()..color = Palette.held);
      if (!bare) {
        _word(canvas, Play.names[i], at + const Offset(0, -13), Palette.held, size, 11, backed: true);
        _word(canvas, "${Play.names[i]}'", shade + const Offset(0, -13), Palette.copper, size, 11, backed: true);
      }
    }
    // The lantern.
    canvas.drawCircle(m.centre, bare ? m.cell * 0.22 : 5, Paint()..color = Palette.lantern);
    if (!bare) {
      canvas.drawCircle(m.centre, 9, Paint()..color = Palette.lantern..style = PaintingStyle.stroke..strokeWidth = 1);
    }
    final aim = pointing;
    if (aim != null && !bare && aim.$1 == 'peg' && play.wanted != null) {
      canvas.drawCircle(m.pegAt(play.wanted!), 12, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    if (aim != null && !bare && aim.$1 == 'lift' && pegs.isNotEmpty) {
      canvas.drawCircle(m.pegAt(pegs.last), 12, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    canvas.restore();
    if (bare || !m.roomy) return;
    final String words;
    if (meetings == null) {
      words = pegs.length < 3
          ? 'pegs ${pegs.length} of 3'
          : 'those three pegs cast no three meetings: pick again';
    } else {
      final far = play.farOff;
      words = far == 3
          ? 'all three meetings far off: the axis is the line at infinity'
          : 'meetings ${meetings.map(Rules.tellPoint).join(', ')}';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), meetings == null ? Palette.inkDim : Palette.gold, size, 11, backed: true);
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
  bool shouldRepaint(ShadowView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
