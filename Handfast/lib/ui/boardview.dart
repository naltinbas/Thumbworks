import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hire/play.dart';
import 'palette.dart';

/// Where everything on the board is.
///
/// The painter and the finger both use this, which is the point of it: a cross
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    final fair = play.fair;
    names = math.min(room.width * 0.34, 128);
    head = math.min(room.height * 0.16, 86);
    wide = (room.width - names) / fair.people;
    tall = math.min((room.height - head) / fair.jobs, 46);
    top = head + (room.height - head - tall * fair.jobs) / 2;
  }

  final Play play;

  /// How much room the work written down the side takes.
  late final double names;

  /// How deep the hands written across the top are.
  late final double head;

  late final double wide;
  late final double tall;
  late final double top;

  Rect cellAt(int job, int hand) =>
      Rect.fromLTWH(names + hand * wide, top + job * tall, wide, tall);

  Rect rowAt(int job) =>
      Rect.fromLTWH(0, top + job * tall, names + wide * play.fair.people, tall);

  Rect columnAt(int hand) => Rect.fromLTWH(
        names + hand * wide + wide * 0.04,
        top - 4,
        wide * 0.92,
        tall * play.fair.jobs + 8,
      );

  /// The job and hand under a point, or (-1, -1).
  (int, int) cellUnder(Offset touch) {
    final job = ((touch.dy - top) / tall).floor();
    if (job < 0 || job >= play.fair.jobs) return (-1, -1);
    if (touch.dx < names) return (job, -1);
    final hand = ((touch.dx - names) / wide).floor();
    if (hand < 0 || hand >= play.fair.people) return (job, -1);
    return (job, hand);
  }
}

/// The board: the work down the side, the hands across the top, and a cross
/// where somebody can take something on.
class BoardView extends CustomPainter {
  const BoardView({
    required this.play,
    required this.showShort,
    required this.pointing,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// Whether to mark the jobs that have too few hands between them, which is
  /// what the game shows when it is asked why there is no more.
  final bool showShort;

  /// A cell the game is pointing at, or (-1, -1).
  final (int, int) pointing;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the crosses.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final fair = play.fair;
    final short = showShort ? play.answer.short.toSet() : const <int>{};
    final only = showShort ? play.answer.onlyThese.toSet() : const <int>{};

    if (showShort) {
      for (final job in short) {
        canvas.drawRect(
          metrics.rowAt(job),
          Paint()..color = Palette.shortOf.withValues(alpha: 0.13),
        );
      }
      for (final hand in only) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            metrics.columnAt(hand),
            Radius.circular(metrics.wide * 0.2),
          ),
          Paint()
            ..color = Palette.shortOf
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    for (var job = 0; job < fair.jobs; job++) {
      final on = play.handOn(job);
      final stuck = on < 0 && !fair.whoCan[job].any(play.isFree);

      if (showWords) {
        final name = TextPainter(
          text: TextSpan(
            text: fair.work[job],
            style: labels.copyWith(
              color: on >= 0
                  ? Palette.taken
                  : stuck
                      ? Palette.bad
                      : Palette.ink,
              fontWeight: on >= 0 ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '.',
        )..layout(maxWidth: metrics.names - 10);
        name.paint(
          canvas,
          Offset(4, metrics.top + job * metrics.tall +
              (metrics.tall - name.height) / 2),
        );
      }

      for (var hand = 0; hand < fair.people; hand++) {
        final cell = metrics.cellAt(job, hand).deflate(metrics.wide * 0.12);
        final round = Radius.circular(metrics.wide * 0.22);

        if (!fair.can(job, hand)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(cell, round),
            Paint()..color = Palette.night,
          );
          continue;
        }

        final isOn = on == hand;
        final open = play.canTake(job, hand);

        canvas.drawRRect(
          RRect.fromRectAndRadius(cell, round),
          Paint()
            ..color = isOn
                ? Palette.taken
                : open
                    ? Palette.verge
                    : Palette.dead,
        );
        if (!isOn) {
          // The cross itself.
          final middle = cell.center;
          final arm = cell.width * 0.2;
          final ink = Paint()
            ..color = open ? Palette.cross : Palette.edge
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(middle - Offset(arm, arm), middle + Offset(arm, arm),
              ink);
          canvas.drawLine(middle - Offset(arm, -arm), middle + Offset(arm, -arm),
              ink);
        } else {
          // A tick, for a job somebody has taken on.
          final middle = cell.center;
          final arm = cell.width * 0.22;
          final ink = Paint()
            ..color = Palette.night
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          canvas.drawPath(
            Path()
              ..moveTo(middle.dx - arm, middle.dy)
              ..lineTo(middle.dx - arm * 0.2, middle.dy + arm * 0.8)
              ..lineTo(middle.dx + arm, middle.dy - arm * 0.7),
            ink,
          );
        }

        if (pointing == (job, hand)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(cell.inflate(2), round),
            Paint()
              ..color = Palette.ink
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.4,
          );
        }
      }
    }

    if (!showWords) return;

    // The hands across the top, written on their sides so the columns can be
    // as narrow as they need to be.
    for (var hand = 0; hand < fair.people; hand++) {
      final name = TextPainter(
        text: TextSpan(
          text: fair.hands[hand],
          style: labels.copyWith(
            color: play.isFree(hand) ? Palette.ink : Palette.taken,
            fontWeight: play.isFree(hand) ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '.',
      )..layout(maxWidth: metrics.head - 6);

      canvas.save();
      canvas.translate(
        metrics.names + hand * metrics.wide + metrics.wide / 2 +
            name.height / 2,
        metrics.top - 8,
      );
      canvas.rotate(-math.pi / 2);
      name.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BoardView old) =>
      old.play != play ||
      old.showShort != showShort ||
      old.pointing != pointing;
}
