import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../green/play.dart';
import 'palette.dart';

/// Where things lie on the board, so the screen and the tests can find
/// them: the grid of points across the green, a hamlet on some of them.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    final n = play.level.size;
    final side = math.min(room.width, room.height) * (bare ? 0.7 : 0.72);
    step = side / (n - 1);
    origin = Offset((room.width - side) / 2, (room.height - side) / 2);
    margin = math.min(step * 0.45, (math.min(room.width, room.height) - side) / 2 - 4);
    hamletRadius = bare ? step * 0.2 : (step * 0.16).clamp(10.0, 22.0);
  }

  final Play play;

  late final double width;
  late final double height;

  /// The distance between grid points.
  late final double step;

  /// Where grid point (0, 0) lies.
  late final Offset origin;
  late final double hamletRadius;

  /// How far the green reaches past the outer grid points.
  late final double margin;

  /// Where grid point (x, y) lies.
  Offset at((int, int) point) => origin + Offset(point.$1 * step, point.$2 * step);

  /// Where hamlet [h] stands.
  Offset hamlet(int h) => at(play.at[h]);

  /// What is under a touch: (1, h, 0) a hamlet, (0, x, y) a bare grid
  /// point, or null.
  (int, int, int)? under(Offset touch) {
    for (var h = 0; h < play.level.hamlets; h++) {
      if ((hamlet(h) - touch).distance <= hamletRadius + 8) return (1, h, 0);
    }
    for (var y = 0; y < play.level.size; y++) {
      for (var x = 0; x < play.level.size; x++) {
        if ((at((x, y)) - touch).distance <= step * 0.4) return (0, x, y);
      }
    }
    return null;
  }
}

/// The green: grid points, lanes as straight lines between hamlets,
/// crossing lanes in rust, hamlets as cottages of two kinds.
class GreenView extends CustomPainter {
  GreenView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The (hamlet, point) the show-me points at, or null.
  final (int, (int, int))? pointing;
  final TextStyle labels;

  /// Whether to leave the words and the grid off, for the mark.
  final bool bare;

  static const names = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.dusk);
    final green = Rect.fromPoints(m.at((0, 0)), m.at((play.level.size - 1, play.level.size - 1))).inflate(m.margin);
    canvas.drawRRect(RRect.fromRectAndRadius(green, Radius.circular(m.step * 0.2)), Paint()..color = Palette.green);
    // The grid points.
    if (!bare) {
      for (var y = 0; y < play.level.size; y++) {
        for (var x = 0; x < play.level.size; x++) {
          canvas.drawCircle(m.at((x, y)), 3, Paint()..color = Palette.dot);
        }
      }
    }
    // The lanes, the crossing ones in rust.
    final bad = <int>{};
    for (final (i, j) in play.crossings) {
      bad.add(i);
      bad.add(j);
    }
    for (final (i, _) in play.throughs) {
      bad.add(i);
    }
    final stroke = bare ? m.step * 0.05 : (m.step * 0.05).clamp(2.0, 6.0);
    for (var i = 0; i < play.lanes.length; i++) {
      final (a, b) = play.lanes[i];
      canvas.drawLine(m.hamlet(a), m.hamlet(b), Paint()
        ..color = bad.contains(i) ? Palette.laneCross : Palette.lane
        ..strokeWidth = bad.contains(i) ? stroke * 1.3 : stroke
        ..strokeCap = StrokeCap.round);
    }
    // The pointer's place.
    if (pointing != null) {
      canvas.drawCircle(m.at(pointing!.$2), m.hamletRadius + 6, Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    // The hamlets.
    for (var h = 0; h < play.level.hamlets; h++) {
      final c = m.hamlet(h);
      final r = m.hamletRadius;
      final kind = play.level.kinds[h];
      final wall = kind == 0 ? Palette.wallA : Palette.wallB;
      final roof = kind == 0 ? Palette.roofA : Palette.roofB;
      // A cottage: a wall with a roof.
      canvas.drawRect(Rect.fromLTWH(c.dx - r * 0.75, c.dy - r * 0.15, r * 1.5, r * 1.05), Paint()..color = wall);
      final gable = Path()
        ..moveTo(c.dx - r * 0.95, c.dy - r * 0.15)
        ..lineTo(c.dx, c.dy - r * 1.05)
        ..lineTo(c.dx + r * 0.95, c.dy - r * 0.15)
        ..close();
      canvas.drawPath(gable, Paint()..color = roof);
      canvas.drawRect(Rect.fromLTWH(c.dx - r * 0.2, c.dy + r * 0.3, r * 0.4, r * 0.6), Paint()..color = roof.withValues(alpha: 0.8));
      if (play.held == h) {
        canvas.drawCircle(c, r + 4, Paint()
          ..color = Palette.held
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
      if (pointing != null && pointing!.$1 == h) {
        canvas.drawCircle(c, r + 8, Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
      if (!bare) {
        _write(canvas, names[h], Offset(c.dx, c.dy + r * 1.55), labels.copyWith(color: Palette.ink, fontSize: (r * 0.8).clamp(9.0, 13.0), fontWeight: FontWeight.w800));
      }
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(GreenView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'Hamlets stand on the points of a grid and lanes run straight between '
      'them; the green is clear when no two lanes cross and no lane runs through a '
      'hamlet not its own, which is a straight-line drawing of a planar graph, and '
      'Fary\'s theorem says every planar graph has one. Euler\'s formula, hamlets '
      'less lanes plus faces equal to two, says which greens never come clear: '
      'every face has three lanes at least and every lane borders two faces, so the '
      'lanes are at most 3v - 6, and where the hamlets are of two kinds with lanes '
      'only between the kinds every face has four at least, so the lanes are at '
      'most 2v - 4. Every placing of the hamlets on the grid is swept for every '
      'green, the lanes judged by whole-number cross products.';
  return '$law ${level.note}';
}
