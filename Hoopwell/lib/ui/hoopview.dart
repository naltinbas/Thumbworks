import 'dart:math';

import 'package:flutter/material.dart';

import '../hoop/play.dart';
import '../hoop/rules.dart';
import 'palette.dart';

/// Where the hoop sits in a board of a given size.
///
/// Three rings on seven spokes, hole 0 at the top and the numbers
/// running round clockwise. The lamps are outermost, the pale stones
/// inside them and the dark stones innermost, so a stone always sits
/// under the lamp its own hole would light.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 22.0;
    final room = Size(size.width - 16, size.height - words - 16);
    middle = Offset(8 + room.width / 2, 8 + words / 2 + room.height / 2);
    // The hole numbers sit outside the lamps, so the drawing is scaled
    // to leave room for them.
    reach = min(room.width, room.height) / 2 / (bare ? 1.06 : 1.24);
    hole = reach * 0.145;
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final Offset middle;
  late final double reach, hole;

  /// Whether there is room for words under the hoop.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  /// The three rings, outermost first: lamps, pale stones, dark stones.
  double ringAt(int ring) => reach * switch (ring) { 0 => 0.44, 1 => 0.73, _ => 1.0 };

  /// Where a hole sits on a ring. Ring 0 is the dark stones, 1 the pale
  /// and 2 the lamps.
  Offset spot(int ring, int hole) {
    final turn = -pi / 2 + 2 * pi * hole / Rules.holes;
    final r = ringAt(ring);
    return middle + Offset(cos(turn) * r, sin(turn) * r);
  }

  /// Where a hole's number is written.
  Offset numberAt(int hole) {
    final turn = -pi / 2 + 2 * pi * hole / Rules.holes;
    final r = reach * 1.19;
    return middle + Offset(cos(turn) * r, sin(turn) * r);
  }

  /// The stone a tap means, as a ring and a hole, or null when it lands
  /// on neither ring of stones.
  (int, int)? stoneNear(Offset touch) {
    (int, int)? best;
    var away = hole * 1.25;
    for (var ring = 0; ring < 2; ring++) {
      for (var h = 0; h < Rules.holes; h++) {
        final d = (spot(ring, h) - touch).distance;
        if (d < away) {
          away = d;
          best = (ring, h);
        }
      }
    }
    return best;
  }
}

/// The hoop, its two rings of stones, and the lamps their sums light.
class HoopView extends CustomPainter {
  const HoopView({
    required this.play,
    this.pointing,
    this.showWhyNot = false,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The stone the show-me points at, or null.
  final (int, int)? pointing;

  /// Whether to draw the walk the finger proof takes, which is the
  /// reason an ask cannot be landed.
  final bool showWhyNot;

  final TextStyle labels;

  /// Whether to draw the hoop alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final lamps = play.lamps;

    // The three rings themselves, drawn as thin hoops.
    for (var ring = 0; ring < 3; ring++) {
      canvas.drawCircle(
        m.middle,
        m.ringAt(ring),
        Paint()
          ..color = Palette.hoop
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 2 : 1.2,
      );
    }

    // The walk, when the hoop is explaining itself: the holes taken in
    // steps of the gap between the two dark stones, which on a hoop of
    // seven passes through every one of them.
    if (showWhyNot && play.walk.isNotEmpty) {
      final order = play.walk;
      final path = Path();
      for (var k = 0; k <= Rules.holes; k++) {
        final at = m.spot(1, order[k % Rules.holes]);
        if (k == 0) {
          path.moveTo(at.dx, at.dy);
        } else {
          path.lineTo(at.dx, at.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.walk.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      // The hole one step past the end of each run of pale stones. It
      // lights and holds no pale stone of its own, which is the lamp
      // the floor is made of.
      for (final end in play.runEnds) {
        canvas.drawCircle(
          m.spot(2, (end + play.step) % Rules.holes),
          m.hole * 1.35,
          Paint()
            ..color = Palette.walk
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    for (var h = 0; h < Rules.holes; h++) {
      final lit = lamps >> h & 1 == 1;
      final hasDark = play.dark >> h & 1 == 1;
      final hasPale = play.pale >> h & 1 == 1;

      // The lamp.
      canvas.drawCircle(m.spot(2, h), m.hole,
          Paint()..color = lit ? Palette.lit : Palette.unlit);
      canvas.drawCircle(
        m.spot(2, h),
        m.hole,
        Paint()
          ..color = lit ? Palette.lit : Palette.socket
          ..style = PaintingStyle.stroke
          ..strokeWidth = lit ? (bare ? 3 : 2) : 1.2,
      );

      // The two rings of stones. An empty hole is drawn as a socket, so
      // the hoop reads the same whether or not a stone is in it.
      for (var ring = 0; ring < 2; ring++) {
        final has = ring == 0 ? hasDark : hasPale;
        final at = m.spot(ring, h);
        canvas.drawCircle(
          at,
          m.hole * 0.86,
          Paint()
            ..color = has
                ? (ring == 0 ? Palette.dark : Palette.pale)
                : Palette.socket.withValues(alpha: 0.35),
        );
        canvas.drawCircle(
          at,
          m.hole * 0.86,
          Paint()
            ..color = has
                ? (ring == 0 ? Palette.darkRim : Palette.pale)
                : Palette.socket
            ..style = PaintingStyle.stroke
            ..strokeWidth = bare ? 2 : 1.1,
        );
        if (!bare && pointing == (ring, h)) {
          canvas.drawCircle(
            at,
            m.hole * 1.35,
            Paint()
              ..color = Palette.shown
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }

      if (!bare) {
        _word(canvas, '$h', m.numberAt(h), Palette.inkDim, size,
            m.hole * 0.72);
      }
    }

    if (bare || !m.roomy) return;
    _word(
      canvas,
      'dark plus pale lights the lamp; the floor here is ${play.floor}',
      Offset(size.width / 2, size.height - 9),
      Palette.inkDim,
      size,
      10,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(HoopView old) =>
      old.play.dark != play.dark ||
      old.play.pale != play.pale ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showWhyNot != showWhyNot ||
      old.bare != bare;
}
