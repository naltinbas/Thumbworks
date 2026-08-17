import 'dart:math';

import 'package:flutter/material.dart';

import '../hall/play.dart';
import '../hall/rules.dart';
import 'palette.dart';

/// Where the field sits in a board of a given size: the points run from
/// [Rules.low] to [Rules.high] both ways, with the hall drawn on them.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    const across = Rules.high - Rules.low;
    final pad = bare ? 16.0 : 22.0;
    step = min(size.width - 2 * pad, size.height - 2 * pad) / across;
    left = (size.width - step * across) / 2;
    bottom = (size.height + step * across) / 2;
    dot = max(1.5, step * 0.12);
  }

  final Size size;
  final bool bare;

  /// How far apart the points of the field stand.
  late final double step;
  late final double left;
  late final double bottom;
  late final double dot;

  Offset at(num x, num y) =>
      Offset(left + (x - Rules.low) * step, bottom - (y - Rules.low) * step);

  /// Which point lies under [where], or null when none is near enough.
  (int, int)? under(Offset where) {
    var best = double.infinity;
    (int, int)? nearest;
    for (var x = Rules.low; x <= Rules.high; x++) {
      for (var y = Rules.low; y <= Rules.high; y++) {
        final far = (at(x, y) - where).distance;
        if (far < best) {
          best = far;
          nearest = (x, y);
        }
      }
    }
    return best <= step * 0.7 ? nearest : null;
  }

  bool get roomy => step >= 16;
}

/// The field, the hall on it, the peg and the four lines from the peg
/// to the posts.
class HallView extends CustomPainter {
  const HallView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (String, int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the hall and the lines alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);

    // The field.
    if (!bare) {
      for (var x = Rules.low; x <= Rules.high; x++) {
        for (var y = Rules.low; y <= Rules.high; y++) {
          canvas.drawCircle(m.at(x, y), m.dot * 0.5,
              Paint()..color = Palette.line);
        }
      }
    }

    // The hall.
    final posts = play.posts;
    final walls = Path()..moveTo(m.at(posts[0].$1, posts[0].$2).dx,
        m.at(posts[0].$1, posts[0].$2).dy);
    for (final post in posts.skip(1)) {
      final at = m.at(post.$1, post.$2);
      walls.lineTo(at.dx, at.dy);
    }
    walls.close();
    canvas.drawPath(walls, Paint()..color = Palette.grass);
    canvas.drawPath(
      walls,
      Paint()
        ..color = Palette.chalk
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.6, m.step * 0.09)
        ..strokeJoin = StrokeJoin.round,
    );

    // The four lines from the peg, a pair to each opposite pair of
    // posts.
    final peg = m.at(play.px, play.py);
    for (var which = 0; which < 4; which++) {
      final post = posts[which];
      canvas.drawLine(
        peg,
        m.at(post.$1, post.$2),
        Paint()
          ..color = which.isEven ? Palette.oneWay : Palette.otherWay
          ..strokeWidth = max(1.4, m.step * 0.07),
      );
    }

    // The posts.
    for (var which = 0; which < 4; which++) {
      final post = posts[which];
      final at = m.at(post.$1, post.$2);
      canvas.drawCircle(at, m.dot * 1.7, Paint()..color = Palette.post);
      if (m.roomy) {
        // The near posts get their names below them and the far ones
        // above, so the walls never run through the letters.
        final below = which == 0 || which == 1;
        _word(
          canvas,
          Rules.names[which],
          at.translate(below ? -m.step * 0.5 : 0, below ? m.step * 0.55 : -m.step * 0.55),
          12,
          Palette.inkDim,
        );
      }
    }

    // The peg.
    canvas.drawCircle(peg, m.dot * 1.9, Paint()..color = Palette.peg);
    canvas.drawCircle(
      peg,
      m.dot * 2.8,
      Paint()
        ..color = Palette.peg
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.2, m.step * 0.06),
    );

    if (pointing != null && pointing!.$1 == 'peg') {
      canvas.drawCircle(
        m.at(pointing!.$2, pointing!.$3),
        m.dot * 3.4,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.6, m.step * 0.08),
      );
    }

    if (bare || !m.roomy) return;
    final squares = play.squares;
    _word(
      canvas,
      'A ${squares[0]} + C ${squares[2]} = ${play.acrossOne}',
      Offset(size.width / 2, m.bottom + 14),
      12,
      Palette.oneWay,
    );
    _word(
      canvas,
      'B ${squares[1]} + D ${squares[3]} = ${play.acrossTwo}',
      Offset(size.width / 2, m.bottom + 30),
      12,
      Palette.otherWay,
    );
  }

  void _word(
    Canvas canvas,
    String words,
    Offset at,
    double size,
    Color colour,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(color: colour, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(HallView old) =>
      old.play != play || old.pointing != pointing;
}
