import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../raise/play.dart';
import 'palette.dart';

/// Where every timber is drawn.
///
/// The painter and the finger both use this, which is the point of it: a
/// timber is where it is drawn, and there is no second sum that could disagree
/// with the first.
class Metrics {
  Metrics(this.play, Size room) {
    final side = math.min(room.width, room.height);
    stout = side * 0.022;
    across = room.width - stout * 2;
    down = room.height - stout * 2;
    corner = Offset(stout, stout);
  }

  final Play play;

  /// How thick an ordinary timber is drawn.
  late final double stout;
  late final double across;
  late final double down;
  late final Offset corner;

  Offset _at(double x, double y) =>
      corner + Offset(x * across, y * down);

  (Offset, Offset) endsOf(int timber) {
    final wood = play.frame.timbers[timber];
    return (_at(wood.fromX, wood.fromY), _at(wood.toX, wood.toY));
  }

  Offset middleOf(int timber) {
    final (one, other) = endsOf(timber);
    return Offset((one.dx + other.dx) / 2, (one.dy + other.dy) / 2);
  }

  /// The timber under a point, or -1. The nearest one within reach, so a thin
  /// brace is no harder to hit than a sill.
  int timberAt(Offset touch) {
    var nearest = -1;
    var best = stout * 3;
    for (var timber = 0; timber < play.frame.count; timber++) {
      final (one, other) = endsOf(timber);
      final away = _awayFrom(touch, one, other);
      if (away < best) {
        best = away;
        nearest = timber;
      }
    }
    return nearest;
  }

  static double _awayFrom(Offset point, Offset one, Offset other) {
    final along = other - one;
    final length = along.distanceSquared;
    if (length == 0) return (point - one).distance;
    final how = (((point - one).dx * along.dx + (point - one).dy * along.dy) /
            length)
        .clamp(0.0, 1.0);
    return (point - (one + along * how)).distance;
  }
}

/// The frame: what is standing, what is ready, and what the crews are on.
class FrameView extends CustomPainter {
  const FrameView({
    required this.play,
    required this.showRun,
    required this.pointing,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// Whether to mark the longest run of timbers each resting on the last,
  /// which is what the game shows when it is asked why it takes what it takes.
  final bool showRun;

  /// A timber the game is pointing at, or -1.
  final int pointing;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the frame.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final frame = play.frame;
    final run = showRun ? play.answer.chain.toSet() : const <int>{};

    for (var timber = 0; timber < frame.count; timber++) {
      final (one, other) = metrics.endsOf(timber);
      final wood = frame.timbers[timber];
      final width = metrics.stout * wood.stout;

      final up = play.isUp(timber);
      final today = play.isToday(timber);
      final ready = play.isReady(timber);

      // The ghost of where it goes, for everything not yet standing.
      if (!up) {
        canvas.drawLine(
          one,
          other,
          Paint()
            ..color = Palette.down
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round,
        );
      }

      canvas.drawLine(
        one,
        other,
        Paint()
          ..color = up
              ? Palette.up
              : today
                  ? Palette.chosen
                  : ready
                      ? Palette.ready
                      : Palette.down
          ..strokeWidth = up || today ? width : width * 0.7
          ..strokeCap = StrokeCap.round,
      );

      if (run.contains(timber)) {
        canvas.drawLine(
          one,
          other,
          Paint()
            ..color = Palette.run
            ..strokeWidth = width * 0.34
            ..strokeCap = StrokeCap.round,
        );
      }

      if (timber == pointing || today) {
        canvas.drawCircle(
          metrics.middleOf(timber),
          width * 1.2,
          Paint()
            ..color = today ? Palette.chosen : Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.stout * 0.3,
        );
      }
    }

    if (!showWords) return;

    // The name of whatever the crews are on, so a player never has to guess
    // which timber they have picked.
    for (final timber in play.today) {
      final name = TextPainter(
        text: TextSpan(
          text: frame.timbers[timber].name,
          style: labels.copyWith(color: Palette.chosen),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final middle = metrics.middleOf(timber);
      final where = middle + Offset(-name.width / 2, metrics.stout * 1.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(where.dx, where.dy, name.width, name.height)
              .inflate(metrics.stout * 0.3),
          Radius.circular(metrics.stout * 0.4),
        ),
        Paint()..color = Palette.night.withValues(alpha: 0.85),
      );
      name.paint(canvas, where);
    }
  }

  @override
  bool shouldRepaint(FrameView old) =>
      old.play != play || old.showRun != showRun || old.pointing != pointing;
}
