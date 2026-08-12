import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ink/play.dart';
import 'palette.dart';

/// Where every post stands and every string hangs, shared by
/// the painter and the hit-testing, so what is drawn is exactly
/// what is tapped.
class Metrics {
  Metrics(this.play, this.room);

  final Play play;
  final Size room;

  /// The middle of a post's head.
  Offset postAt(int post) {
    final (x, y) = play.line.spots[post];
    return Offset(
      room.width * (0.08 + 0.84 * x),
      room.height * (0.08 + 0.78 * y),
    );
  }

  /// A string's hang, sampled along its sag.
  List<Offset> stringPoints(int string) {
    final (a, b) = play.line.strings[string];
    final from = postAt(a);
    final to = postAt(b);
    final sag = (to - from).distance * 0.16;
    final control =
        Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2 + sag);
    return [
      for (var step = 0; step <= 10; step++)
        _bend(from, control, to, step / 10),
    ];
  }

  Offset _bend(Offset a, Offset c, Offset b, double t) =>
      a * (1 - t) * (1 - t) + c * 2 * (1 - t) * t + b * t * t;

  /// A tap-worthy point of a string's hang, staggered along
  /// the sag so crossing strings never share it: the two
  /// diagonals of a square sag to the same midpoint.
  Offset midOf(int string) =>
      stringPoints(string)[3 + (string % 4)];

  /// The string under a touch, or -1 for the green.
  int stringUnder(Offset touch) {
    var found = -1;
    var nearest = math.min(room.width, room.height) * 0.09;
    for (var string = 0; string < play.line.strings.length; string++) {
      for (final at in stringPoints(string)) {
        final off = (at - touch).distance;
        if (off < nearest) {
          nearest = off;
          found = string;
        }
      }
    }
    return found;
  }
}

/// The bunting, drawn: posts, sagging strings, and pennants in
/// whatever ink each string wears.
class InkView extends CustomPainter {
  InkView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The string the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final scale = math.min(size.width, size.height);

    // The posts clashing anywhere, to rim rust.
    final sore = <int>{};
    for (final (one, two) in play.clashes) {
      final (a, b) = play.line.strings[one];
      final (c, d) = play.line.strings[two];
      for (final post in [a, b]) {
        if (post == c || post == d) sore.add(post);
      }
    }

    // The strings, sagging, pennants along the inked ones.
    for (var string = 0; string < play.line.strings.length; string++) {
      final dipped = play.inks[string];
      final points = metrics.stringPoints(string);
      final rope = Path()..moveTo(points.first.dx, points.first.dy);
      for (final at in points.skip(1)) {
        rope.lineTo(at.dx, at.dy);
      }
      canvas.drawPath(
        rope,
        Paint()
          ..color =
              dipped == 0 ? Palette.bare : Palette.ofInk(dipped)
          ..style = PaintingStyle.stroke
          ..strokeWidth = dipped == 0 ? 2.0 : 3.4
          ..strokeCap = StrokeCap.round,
      );
      if (dipped != 0) {
        for (final t in const [2, 4, 6, 8]) {
          final hang = points[t];
          final along = points[t + 1] - points[t - 1];
          final way = along / along.distance;
          final drop = scale * 0.028;
          canvas.drawPath(
            Path()
              ..moveTo(hang.dx - way.dx * drop * 0.7,
                  hang.dy - way.dy * drop * 0.7)
              ..lineTo(hang.dx + way.dx * drop * 0.7,
                  hang.dy + way.dy * drop * 0.7)
              ..lineTo(hang.dx + drop * 0.25, hang.dy + drop * 1.5)
              ..close(),
            Paint()..color = Palette.ofInk(dipped),
          );
        }
      }
      if (pointing == string) {
        canvas.drawCircle(
          metrics.midOf(string),
          scale * 0.055,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The posts, sore ones rimmed rust.
    for (var post = 0; post < play.line.posts; post++) {
      final at = metrics.postAt(post);
      canvas.drawLine(
        at,
        at + Offset(0, scale * 0.05),
        Paint()
          ..color = Palette.post
          ..strokeWidth = 3.4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
          at, scale * 0.021, Paint()..color = Palette.post);
      if (sore.contains(post)) {
        canvas.drawCircle(
          at,
          scale * 0.042,
          Paint()
            ..color = Palette.clash
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }
  }

  @override
  bool shouldRepaint(InkView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the line at hand.
String whyWords(Play play) {
  final line = play.line;
  final note = line.note == null ? '' : ' ${line.note}';
  final sweep = math.pow(line.pot, line.strings.length).round();
  if (!line.winnable) {
    return 'Two inks on a ring can only take turns: every string '
        'must differ from the string before, so the inks alternate '
        'all the way round, and an odd ring hands its last string '
        'the same ink as its first. The sweep dipped all $sweep '
        'inkings of the five and none lands.$note';
  }
  return 'A landing is read two ways that share nothing: the '
      'clash census walks every post\'s strings pair by pair, and '
      'the sweep dips all $sweep inkings of the line and counts '
      'the landings outright. ${line.ways} '
      'inking${line.ways == 1 ? '' : 's'} '
      'land${line.ways == 1 ? 's' : ''} this line.$note';
}
