import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../score/play.dart';
import 'palette.dart';

/// Where the ring and the walk lie, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.26);
    round = math.min(room.width, room.height * 0.5) * 0.3;
    walkTop = room.height * 0.56;
    walkBottom = room.height * 0.94;
    walkLeft = room.width * 0.1;
    walkRight = room.width * 0.9;
  }

  final Play play;

  late final Offset middle;
  late final double round;
  late final double walkTop;
  late final double walkBottom;
  late final double walkLeft;
  late final double walkRight;

  /// Where a mark sits on the ring, the first at the top.
  Offset markAt(int at) {
    final turn =
        -math.pi / 2 + at * 2 * math.pi / play.ring.marks.length;
    return middle + Offset(math.cos(turn), math.sin(turn)) * round;
  }

  /// The mark under a touch, or null.
  int? markUnder(Offset touch) {
    for (var at = 0; at < play.ring.marks.length; at++) {
      if ((markAt(at) - touch).distance <= round * 0.38) return at;
    }
    return null;
  }
}

/// The ring and the walk, drawn.
class ScoreView extends CustomPainter {
  ScoreView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The mark being pointed at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final marks = play.ring.marks;

    // The ring's cord.
    canvas.drawCircle(
      metrics.middle,
      metrics.round,
      Paint()
        ..color = Palette.post
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    for (var at = 0; at < marks.length; at++) {
      final spot = metrics.markAt(at);
      final up = marks[at] == 1;
      final reach = metrics.round * 0.22;

      if (play.found.contains(at)) {
        canvas.drawCircle(
          spot,
          metrics.round * 0.34,
          Paint()
            ..color = Palette.good
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      } else if (at == pointing) {
        canvas.drawCircle(
          spot,
          metrics.round * 0.34,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      } else if (play.tried.contains(at)) {
        canvas.drawCircle(
          spot,
          metrics.round * 0.3,
          Paint()
            ..color = Palette.line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }

      // The mark itself: a notch up in gold, a wipe down in rust.
      canvas.drawLine(
        spot + Offset(-reach * 0.5, up ? reach : -reach),
        spot + Offset(reach * 0.5, up ? -reach : reach),
        Paint()
          ..color = up ? Palette.notch : Palette.wipe
          ..strokeWidth = 3.4
          ..strokeCap = StrokeCap.round,
      );
    }

    _walk(canvas, metrics);
  }

  void _walk(Canvas canvas, Metrics metrics) {
    final walk = play.shownWalk;

    if (walk.isEmpty) {
      // The bare ground, waiting for a walk.
      canvas.drawLine(
        Offset(metrics.walkLeft, metrics.walkBottom - 6),
        Offset(metrics.walkRight, metrics.walkBottom - 6),
        Paint()
          ..color = Palette.ground
          ..strokeWidth = 2.0,
      );
      return;
    }

    var highest = 1;
    var lowest = 0;
    for (final tally in walk) {
      highest = math.max(highest, tally);
      lowest = math.min(lowest, tally);
    }
    // The whole range, ground included, fits between the walk's
    // top and bottom; nothing paints outside the canvas.
    final span = highest - lowest;
    final rise = (metrics.walkBottom - metrics.walkTop) /
        math.max(span, 1);
    final lane =
        (metrics.walkRight - metrics.walkLeft) / walk.length;

    double heightOf(int tally) =>
        metrics.walkBottom - rise * (tally - lowest);

    // The ground, wherever nought falls in the range.
    canvas.drawLine(
      Offset(metrics.walkLeft, heightOf(0)),
      Offset(metrics.walkRight, heightOf(0)),
      Paint()
        ..color = Palette.ground
        ..strokeWidth = 2.0,
    );

    var from = Offset(metrics.walkLeft, heightOf(0));
    for (var step = 0; step < walk.length; step++) {
      final to = Offset(
        metrics.walkLeft + lane * (step + 1),
        heightOf(walk[step]),
      );
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = play.shownGood
              ? Palette.good
              : Palette.walkLine
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
      if (walk[step] <= 0) {
        canvas.drawCircle(
            to, 5, Paint()..color = Palette.dip);
      }
      from = to;
    }
  }

  @override
  bool shouldRepaint(ScoreView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the ring at hand.
String whyWords(Play play) {
  final ring = play.ring;
  final note = ring.note == null ? '' : ' ${ring.note}';
  final notches = ring.marks.where((mark) => mark == 1).length;
  final wipes = ring.marks.length - notches;
  if (!ring.winnable) {
    return 'A ring holds exactly as many good starts as it runs '
        'ahead, notches over wipes: $notches to $wipes here runs '
        'nothing ahead, so no start of the ${ring.marks.length} '
        'keeps the tally off the ground. The walk, trying every '
        'one, says the same; the two agree on every ring of up to '
        'a dozen marks, all 8,190 of them.$note';
  }
  return 'A ring holds exactly as many good starts as it runs '
      'ahead, notches over wipes: $notches to $wipes runs '
      '${ring.goods} ahead, so exactly ${ring.goods} of the '
      '${ring.marks.length} starts stay off the ground. The one '
      'just past the tally\'s last lowest ebb is always among '
      'them, found without trying; the walk, the ledger, and the '
      'ebb agree on every ring of up to a dozen marks, all 8,190 '
      'of them.$note';
}
