import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../green/play.dart';
import '../green/rules.dart';
import 'palette.dart';

/// Where every side stands, shared by the painter and the hit-testing,
/// so where a badge is drawn is exactly where a badge is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    middle = Offset(width / 2, height / 2);
    around = math.min(width, height) / 2 * 0.78;
    badge = math.min(
      around * math.sin(math.pi / play.green.sides) * 0.9,
      around * 0.2,
    );
  }

  final Play play;

  late final double width;
  late final double height;
  late final Offset middle;
  late final double around;
  late final double badge;

  /// Where a side's badge stands: the last side at the hub, the rest
  /// round the rim.
  Offset badgeAt(int side) {
    if (side == play.green.sides - 1) return middle;
    final turn =
        -math.pi / 2 + side * 2 * math.pi / (play.green.sides - 1);
    return middle + Offset(math.cos(turn), math.sin(turn)) * around;
  }

  /// The side under a touch, or -1 for nowhere.
  int sideAt(Offset touch) {
    for (var side = 0; side < play.green.sides; side++) {
      if ((badgeAt(side) - touch).distance <= badge * 1.5) return side;
    }
    return -1;
  }
}

/// The green, drawn.
class GreenView extends CustomPainter {
  GreenView({
    required this.play,
    required this.pointing,
    required this.showWheel,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The pairing being pointed at, or null.
  final (int, int)? pointing;

  /// Whether to lay the wheel's pairings for this round as ghosts.
  final bool showWheel;

  /// Whether numbers may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    if (showWheel && !play.isWritten) {
      final ghost = Paint()
        ..color = Palette.ghost.withValues(alpha: 0.6)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (final (a, b) in
          Rules.wheelRound(play.green.sides, play.rounds.length)) {
        canvas.drawLine(
            metrics.badgeAt(a), metrics.badgeAt(b), ghost);
      }
    }

    final match = Paint()
      ..color = Palette.match
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final (a, b) in play.current) {
      canvas.drawLine(metrics.badgeAt(a), metrics.badgeAt(b), match);
    }

    if (pointing != null) {
      canvas.drawLine(
        metrics.badgeAt(pointing!.$1),
        metrics.badgeAt(pointing!.$2),
        Paint()
          ..color = Palette.shown
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var side = 0; side < play.green.sides; side++) {
      _badge(canvas, metrics, side);
    }
  }

  void _badge(Canvas canvas, Metrics metrics, int side) {
    final where = metrics.badgeAt(side);
    final colour = Palette.badges[side % Palette.badges.length];
    canvas.drawCircle(
      where,
      metrics.badge,
      Paint()..color = colour,
    );
    if (play.chosen == side) {
      canvas.drawCircle(
        where,
        metrics.badge * 1.3,
        Paint()
          ..color = Palette.picked
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    } else if (play.busy(side)) {
      canvas.drawCircle(
        where,
        metrics.badge,
        Paint()
          ..color = Palette.match
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '${side + 1}',
        style: labels.copyWith(
          color: Palette.evening,
          fontSize: metrics.badge * 0.9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(canvas, where - Offset(words.width / 2, words.height / 2));
  }

  @override
  bool shouldRepaint(GreenView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showWheel != showWheel;
}

/// The words the why speaks, from the green at hand.
String whyWords(Play play) {
  final green = play.green;
  if (!green.possible) {
    return 'Each side has ${green.sides - 1} sides to meet and meets at '
        'most one a round: ${green.sides - 1} rounds at the least, and '
        'this card allows ${green.rounds}. That is the whole proof.'
        '${green.note == null ? '' : ' ${green.note}'}';
  }
  return 'The wheel writes the card with no search: sit side '
      '${green.sides} at the hub, the rest round a rim, pair the hub '
      'with the top and the rim across itself, then turn the rim one '
      'notch a round. The gold lines are the wheel\'s pairings for the '
      'round in hand, and the sweep has checked every pair of every '
      'size is met exactly once.'
      '${green.note == null ? '' : ' ${green.note}'}';
}
