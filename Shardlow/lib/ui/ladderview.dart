import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../drop/play.dart';
import 'palette.dart';

/// Where the ladder and everything on it is.
///
/// The painter and the finger both use this, which is the point of it: a rung
/// is where it is drawn, and there is no second sum that could disagree with
/// the first. Ladders taller than the screen scale their rungs down and keep
/// every one reachable.
class Metrics {
  Metrics(this.play, Size room) {
    this.room = room;
    final rungs = play.ladder.rungs;
    top = room.height * 0.04;
    bottom = room.height * 0.96;
    gap = (bottom - top) / rungs;
    railLeft = room.width * 0.30;
    railRight = room.width * 0.58;
  }

  final Play play;
  late final Size room;

  late final double top;
  late final double bottom;
  late final double gap;
  late final double railLeft;
  late final double railRight;

  /// Where a rung's line is. Rung 1 is at the bottom.
  double yOf(int rung) => bottom - rung * gap;

  /// The rung under a point, or -1.
  int rungAt(Offset touch) {
    final rung = ((bottom - touch.dy) / gap).round();
    if (rung < 1 || rung > play.ladder.rungs) return -1;
    if (touch.dx < railLeft - gap * 2 || touch.dx > railRight + gap * 4) {
      return -1;
    }
    return rung;
  }
}

/// The ladder: the rungs, what happened on them, and what is still possible.
class LadderView extends CustomPainter {
  const LadderView({
    required this.play,
    required this.pointing,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// A rung the game is pointing at, or -1.
  final int pointing;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the ladder.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final ladder = play.ladder;
    final standing = play.standing;

    // The band where the answer still might be.
    if (!play.isDone && standing.highest >= standing.lowest + 1) {
      canvas.drawRect(
        Rect.fromLTRB(
          metrics.railLeft - metrics.gap,
          metrics.yOf(standing.highest) - metrics.gap * 0.4,
          metrics.railRight + metrics.gap,
          metrics.yOf(standing.lowest + 1) + metrics.gap * 0.4,
        ),
        Paint()..color = Palette.maybe.withValues(alpha: 0.24),
      );
    }

    // The rails.
    for (final x in [metrics.railLeft, metrics.railRight]) {
      canvas.drawLine(
        Offset(x, metrics.top - metrics.gap * 0.2),
        Offset(x, metrics.bottom + metrics.gap * 0.2),
        Paint()
          ..color = Palette.wood
          ..strokeWidth = math.min(metrics.gap * 0.22, 7)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The rungs, and what happened on each.
    for (var rung = 1; rung <= ladder.rungs; rung++) {
      final y = metrics.yOf(rung);
      final word = play.wordOn(rung);
      final worth = play.worthDropping(rung) && !play.isDone;

      canvas.drawLine(
        Offset(metrics.railLeft, y),
        Offset(metrics.railRight, y),
        Paint()
          ..color = word == 1
              ? Palette.shard
              : word == 0
                  ? Palette.lived
                  : worth
                      ? Palette.edge
                      : Palette.line
          ..strokeWidth = math.min(metrics.gap * 0.18, 5)
          ..strokeCap = StrokeCap.round,
      );

      // What became of a pot dropped here, off the right rail.
      final tell = metrics.railRight + metrics.gap * 1.2;
      if (word == 1) {
        // Shards: three small triangles.
        final paint = Paint()..color = Palette.shard;
        final r = math.min(metrics.gap * 0.34, 8.0);
        for (final (dx, dy, turn) in [
          (0.0, 0.0, 0.3),
          (r * 1.2, r * 0.4, 1.4),
          (r * 0.4, -r * 0.9, 2.6),
        ]) {
          final mid = Offset(tell + dx, y + dy);
          final path = Path();
          for (var corner = 0; corner < 3; corner++) {
            final angle = turn + corner * 2.1;
            final at = mid +
                Offset(math.cos(angle), math.sin(angle)) * r * 0.6;
            if (corner == 0) {
              path.moveTo(at.dx, at.dy);
            } else {
              path.lineTo(at.dx, at.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
        }
      } else if (word == 0) {
        // A whole pot.
        _pot(canvas, Offset(tell, y), math.min(metrics.gap * 0.5, 10.0),
            Palette.lived);
      }

      if (rung == pointing) {
        canvas.drawCircle(
          Offset((metrics.railLeft + metrics.railRight) / 2, y),
          math.min(metrics.gap * 0.7, 14),
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }

      // Rung numbers, sparsely on tall ladders.
      if (!showWords) continue;
      final every = ladder.rungs > 40 ? 10 : (ladder.rungs > 15 ? 5 : 1);
      if (rung % every != 0 && rung != 1) continue;
      final number = TextPainter(
        text: TextSpan(
          text: '$rung',
          style: labels.copyWith(
            color: Palette.inkDim,
            fontSize: math.min(metrics.gap * 0.6, 11.0),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      number.paint(
        canvas,
        Offset(metrics.railLeft - metrics.gap * 0.8 - number.width,
            y - number.height / 2),
      );
    }

    // The pots still in hand, top right.
    if (showWords) {
      for (var pot = 0; pot < play.hand; pot++) {
        _pot(
          canvas,
          Offset(size.width * 0.86 - pot * size.width * 0.09,
              size.height * 0.06),
          size.width * 0.032,
          Palette.pot,
        );
      }
    }
  }

  void _pot(Canvas canvas, Offset middle, double r, Color colour) {
    final path = Path()
      ..moveTo(middle.dx - r * 0.9, middle.dy - r)
      ..lineTo(middle.dx + r * 0.9, middle.dy - r)
      ..lineTo(middle.dx + r * 0.6, middle.dy + r)
      ..lineTo(middle.dx - r * 0.6, middle.dy + r)
      ..close();
    canvas.drawPath(path, Paint()..color = colour);
    canvas.drawLine(
      Offset(middle.dx - r * 1.1, middle.dy - r),
      Offset(middle.dx + r * 1.1, middle.dy - r),
      Paint()
        ..color = colour
        ..strokeWidth = r * 0.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(LadderView old) =>
      old.play != play || old.pointing != pointing;
}
