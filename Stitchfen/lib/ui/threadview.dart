import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../thread/play.dart';
import 'palette.dart';

/// Where every stitch sits, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    step = math.min(
      room.width * 0.88 / play.row.stitches,
      room.height * 0.2,
    );
    left = (room.width - step * play.row.stitches) / 2;
    middle = room.height * 0.42;
  }

  final Play play;

  late final double step;
  late final double left;
  late final double middle;

  /// The point of a stitch.
  Offset stitchAt(int stitch) =>
      Offset(left + (stitch + 0.5) * step, middle);

  /// The stitch under a touch, or -1.
  int stitchUnder(Offset touch) {
    for (var at = 0; at < play.row.stitches; at++) {
      if ((stitchAt(at) - touch).distance <= step * 0.42) {
        return at;
      }
    }
    return -1;
  }
}

/// The sampler row, drawn.
class ThreadView extends CustomPainter {
  ThreadView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The stitch the show-me points at, or null.
  final (int, String)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The cloth behind the row.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, metrics.middle),
          width: metrics.step * play.row.stitches +
              metrics.step * 0.6,
          height: metrics.step * 1.5,
        ),
        Radius.circular(metrics.step * 0.3),
      ),
      Paint()..color = Palette.cloth,
    );

    // Every ladder, drawn as rungs beneath the row, each at its
    // own depth so they never pile up.
    final ladders = play.ladders;
    for (var at = 0; at < ladders.length; at++) {
      final (start, spread) = ladders[at];
      final depth = metrics.middle +
          metrics.step * (1.1 + 0.42 * at.toDouble());
      final coat = Paint()
        ..color = Palette.ladder
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      final ends = [start, start + spread, start + 2 * spread];
      canvas.drawLine(
        Offset(metrics.stitchAt(ends.first).dx, depth),
        Offset(metrics.stitchAt(ends.last).dx, depth),
        coat,
      );
      for (final end in ends) {
        canvas.drawLine(
          Offset(metrics.stitchAt(end).dx,
              metrics.middle + metrics.step * 0.5),
          Offset(metrics.stitchAt(end).dx, depth),
          coat..strokeWidth = 1.6,
        );
      }
    }

    // The stitches: crosses of thread on the cloth.
    for (var at = 0; at < play.row.stitches; at++) {
      final middle = metrics.stitchAt(at);
      final arm = metrics.step * 0.26;
      final fixed = !play.canFlip(at);
      final coat = Paint()
        ..color = fixed
            ? Palette.threadOf(play.threads[at])
                .withValues(alpha: 0.55)
            : Palette.threadOf(play.threads[at])
        ..strokeWidth = math.max(metrics.step * 0.14, 4.0)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(middle + Offset(-arm, -arm),
          middle + Offset(arm, arm), coat);
      canvas.drawLine(middle + Offset(-arm, arm),
          middle + Offset(arm, -arm), coat);
      if (pointing?.$1 == at) {
        canvas.drawCircle(
          middle,
          metrics.step * 0.44,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: '${at + 1}',
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: metrics.step * 0.26,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(
          canvas,
          middle +
              Offset(-words.width / 2, -metrics.step * 1.05),
        );
      }
    }
  }

  @override
  bool shouldRepaint(ThreadView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the row at hand.
String whyWords(Play play) {
  final row = play.row;
  final threadings = 1 << row.stitches;
  final note = row.note == null ? '' : ' ${row.note}';
  if (!row.winnable) {
    return 'Van der Waerden\'s theorem starts here: two threads '
        'cannot carry nine stitches without three evenly spaced '
        'sharing one. The census reads every ladder off the row, '
        'and the sweep threaded all $threadings rows of '
        '${row.stitches} and found a ladder in every single '
        'one.$note';
  }
  return 'The census reads every ladder off the row, start and '
      'step by start and step, and the sweep threads all '
      '$threadings rows of ${row.stitches}, agreeing with the '
      'prefix ledger that re-adds it in eight parts: '
      '${row.ways} threading${row.ways == 1 ? '' : 's'} land'
      '${row.ways == 1 ? 's' : ''} this row\'s asking.$note';
}
