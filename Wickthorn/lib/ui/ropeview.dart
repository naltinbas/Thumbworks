import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../rope/play.dart';
import 'palette.dart';

/// Where every lantern stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.5);
    ring = math.min(room.width, room.height) * 0.4;
  }

  final Play play;

  late final Offset middle;
  late final double ring;

  /// The point of a lantern, counted clockwise from the top.
  Offset lanternAt(int lantern) {
    final turn = -math.pi / 2 +
        2 * math.pi * lantern / play.green.lanterns;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The lantern under a touch, or -1.
  int lanternUnder(Offset touch) {
    for (var at = 0; at < play.green.lanterns; at++) {
      if ((lanternAt(at) - touch).distance <= ring * 0.24) {
        return at;
      }
    }
    return -1;
  }
}

/// The green, drawn.
class RopeView extends CustomPainter {
  RopeView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The rope the show-me points at, or null.
  final (int, int, int)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The ropes, each a triangle of the ring, the given ones
    // worn dim.
    final ropes = play.ropes;
    final given = play.green.given.length;
    for (var at = 0; at < ropes.length; at++) {
      final (a, b, c) = ropes[at];
      final coat = Palette.ropes[at % Palette.ropes.length];
      final path = Path()
        ..moveTo(metrics.lanternAt(a).dx, metrics.lanternAt(a).dy)
        ..lineTo(metrics.lanternAt(b).dx, metrics.lanternAt(b).dy)
        ..lineTo(metrics.lanternAt(c).dx, metrics.lanternAt(c).dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color =
              at < given ? coat.withValues(alpha: 0.42) : coat
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(metrics.ring * 0.028, 2.6)
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Every clashing pair, called out in rust over the ropes.
    for (final (a, b) in play.clashes) {
      canvas.drawLine(
        metrics.lanternAt(a),
        metrics.lanternAt(b),
        Paint()
          ..color = Palette.clash
          ..strokeWidth = math.max(metrics.ring * 0.05, 4.0)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointed rope, ringed blue round its three lanterns.
    final aim = pointing;
    if (aim != null) {
      for (final lantern in [aim.$1, aim.$2, aim.$3]) {
        canvas.drawCircle(
          metrics.lanternAt(lantern),
          metrics.ring * 0.21,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The lanterns, glowing over everything.
    for (var at = 0; at < play.green.lanterns; at++) {
      final middle = metrics.lanternAt(at);
      final picked = play.picked.contains(at);
      canvas.drawCircle(
        middle,
        metrics.ring * 0.15,
        Paint()..color = Palette.glow.withValues(alpha: 0.22),
      );
      canvas.drawCircle(
          middle, metrics.ring * 0.1, Paint()..color = Palette.glow);
      canvas.drawCircle(
        middle,
        metrics.ring * 0.045,
        Paint()..color = Palette.flame,
      );
      canvas.drawCircle(
        middle,
        metrics.ring * 0.1,
        Paint()
          ..color = picked ? Palette.shown : Palette.glowDim
          ..style = PaintingStyle.stroke
          ..strokeWidth = picked ? 3.0 : 1.4,
      );
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: '${at + 1}',
            style: labels.copyWith(
              color: Palette.ink,
              fontSize: metrics.ring * 0.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(
          canvas,
          middle + Offset(-words.width / 2, metrics.ring * 0.155),
        );
      }
    }
  }

  @override
  bool shouldRepaint(RopeView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the green at hand.
String whyWords(Play play) {
  final green = play.green;
  final rules = play.rules;
  final note = green.note == null ? '' : ' ${green.note}';
  if (!green.winnable) {
    return 'Three voices refuse this green. The pair ledger: '
        '${rules.pairsNeeded} pairs divide into '
        '${rules.ropesNeeded} ropes, so far so good. The lantern '
        'arithmetic: each lantern must share a rope with '
        '${green.lanterns - 1} others, two at a time, and '
        '${green.lanterns - 1} is odd, so no whole count of ropes '
        'serves. The search: every roping of ${green.lanterns} '
        'walked to its end, and not one closing among them.$note';
  }
  return 'A closing is checked three ways that share nothing: the '
      'pair ledger holds every one of ${rules.pairsNeeded} pairs '
      'to exactly one rope, the lantern arithmetic stands every '
      'lantern in exactly ${(green.lanterns - 1) ~/ 2} '
      'rope${(green.lanterns - 1) ~/ 2 == 1 ? '' : 's'}, and the '
      'search strings every roping from what is given and counts '
      '${green.ways} closing${green.ways == 1 ? '' : 's'}.$note';
}
