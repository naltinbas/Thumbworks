import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fold/play.dart';
import 'palette.dart';

/// Where everything on the fold is.
///
/// The painter and the finger both use this, which is the point of it: a gate
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    final side = math.min(room.width, room.height);
    spot = side * 0.034;
    final margin = spot * 3;
    across = room.width - margin * 2;
    down = room.height - margin * 2;
    corner = Offset(margin, margin);
  }

  final Play play;

  late final double spot;
  late final double across;
  late final double down;
  late final Offset corner;

  Offset middleOf(int gate) =>
      corner +
      Offset(play.fold.gates[gate].x * across,
          play.fold.gates[gate].y * down);

  /// The gate under a point, or -1.
  int gateAt(Offset touch) {
    var nearest = -1;
    var best = spot * 2.4;
    for (var gate = 0; gate < play.fold.count; gate++) {
      final away = (middleOf(gate) - touch).distance;
      if (away < best) {
        best = away;
        nearest = gate;
      }
    }
    return nearest;
  }
}

/// The fold: lanes going from dark to watched, gates, shepherds, and the
/// matching when the game is explaining itself.
class FoldView extends CustomPainter {
  const FoldView({
    required this.play,
    required this.pointing,
    required this.showMatching,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// A gate the game is pointing at, or -1.
  final int pointing;

  /// Whether to draw the matching, the lanes that pairwise keep apart.
  final bool showMatching;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the lanes.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final fold = play.fold;
    final matching =
        showMatching ? play.watch.matching.toSet() : const <int>{};

    for (var lane = 0; lane < fold.many; lane++) {
      final one = metrics.middleOf(fold[lane].from);
      final other = metrics.middleOf(fold[lane].to);
      final watched = play.laneWatched(lane);
      final paired = matching.contains(lane);

      canvas.drawLine(
        one,
        other,
        Paint()
          ..color = paired
              ? Palette.pair
              : watched
                  ? Palette.watched
                  : Palette.dark
          ..strokeWidth = paired
              ? metrics.spot * 0.5
              : watched
                  ? metrics.spot * 0.34
                  : metrics.spot * 0.16
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var gate = 0; gate < fold.count; gate++) {
      final middle = metrics.middleOf(gate);
      final posted = play.isPosted(gate);

      // The gate: a little five barred hurdle.
      final wide = metrics.spot * 1.5;
      final tall = metrics.spot * 1.1;
      final frame = Rect.fromCenter(
        center: middle,
        width: wide,
        height: tall,
      );
      canvas.drawRect(frame, Paint()..color = Palette.night);
      final bars = Paint()
        ..color = posted ? Palette.shepherd : Palette.gate
        ..strokeWidth = metrics.spot * 0.13;
      for (var bar = 0; bar < 3; bar++) {
        final y = frame.top + tall * (bar + 0.5) / 3;
        canvas.drawLine(Offset(frame.left, y), Offset(frame.right, y), bars);
      }
      canvas.drawRect(
        frame,
        Paint()
          ..color = posted ? Palette.shepherd : Palette.gate
          ..style = PaintingStyle.stroke
          ..strokeWidth = metrics.spot * 0.16,
      );

      // The shepherd, a warm figure above a posted gate.
      if (posted) {
        canvas.drawCircle(
          middle - Offset(0, tall * 1.05),
          metrics.spot * 0.42,
          Paint()..color = Palette.shepherd,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: middle - Offset(0, tall * 0.55),
              width: metrics.spot * 0.62,
              height: metrics.spot * 0.6,
            ),
            Radius.circular(metrics.spot * 0.2),
          ),
          Paint()..color = Palette.shepherd,
        );
      }

      if (gate == pointing) {
        canvas.drawCircle(
          middle,
          metrics.spot * 1.9,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.spot * 0.14,
        );
      }

      if (!showWords) continue;
      final name = TextPainter(
        text: TextSpan(
          text: fold.gates[gate].name,
          style: labels.copyWith(
            color: posted ? Palette.shepherd : Palette.inkDim,
            fontWeight: posted ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final where = middle + Offset(-name.width / 2, metrics.spot * 1.05);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(where.dx, where.dy, name.width, name.height)
              .inflate(2.4),
          const Radius.circular(3),
        ),
        Paint()..color = Palette.night.withValues(alpha: 0.85),
      );
      name.paint(canvas, where);
    }
  }

  @override
  bool shouldRepaint(FoldView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showMatching != showMatching;
}
