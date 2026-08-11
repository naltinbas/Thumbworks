import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../griddle/fewest.dart';
import '../griddle/play.dart';
import 'palette.dart';

/// Where everything lies, shared by the painter and the hit-testing, so
/// where a cake is drawn is exactly where a cake is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;

    final many = play.cakes.length;
    cakeHigh = math.min(height / (many + 2.6), width * 0.16);
    plateY = height - cakeHigh * 1.1;
    widest = math.min(width * 0.86, cakeHigh * 7.2);
  }

  final Play play;

  late final double width;
  late final double height;
  late final double cakeHigh;

  /// Where the griddle plate lies.
  late final double plateY;

  /// How wide the biggest cake is drawn.
  late final double widest;

  /// How wide a cake of this size is drawn.
  double wideFor(int size) =>
      widest * (0.34 + 0.66 * size / play.cakes.length);

  /// The cake so far up the stack, nought sitting on the griddle.
  Rect cakeRect(int at) {
    final wide = wideFor(play.cakes[at]);
    final bottom = plateY - at * (cakeHigh + 3);
    return Rect.fromLTWH(
      (width - wide) / 2,
      bottom - cakeHigh,
      wide,
      cakeHigh,
    );
  }

  /// The cake under a touch, by its row, or -1 for nowhere. The touch may
  /// land in the margin beside a narrow cake: the row is what counts, so a
  /// finger need not hit a small cake dead on.
  int cakeAt(Offset touch) {
    for (var at = 0; at < play.cakes.length; at++) {
      final row = cakeRect(at);
      if (touch.dy >= row.top - 1.5 && touch.dy <= row.bottom + 1.5) {
        return at;
      }
    }
    return -1;
  }
}

/// The griddle, drawn.
class GriddleView extends CustomPainter {
  GriddleView({
    required this.play,
    required this.pointing,
    required this.showGaps,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The cake the slice is being slid under, or -1.
  final int pointing;

  /// Whether to mark the gaps.
  final bool showGaps;

  /// Whether to brand the sizes on. Off only for the mark, where they would
  /// be a smudge.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    _plate(canvas, metrics);
    for (var at = 0; at < play.cakes.length; at++) {
      _cake(canvas, metrics, at);
    }
    if (showGaps) _gaps(canvas, metrics);
    if (pointing >= 0) _slice(canvas, metrics);
  }

  void _plate(Canvas canvas, Metrics metrics) {
    final wide = metrics.widest * 1.12;
    final plate = Rect.fromLTWH(
      (metrics.width - wide) / 2,
      metrics.plateY,
      wide,
      metrics.cakeHigh * 0.34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(plate, Radius.circular(plate.height * 0.5)),
      Paint()..color = Palette.plate,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(plate, Radius.circular(plate.height * 0.5)),
      Paint()
        ..color = Palette.plateRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // A stumpy leg at each end.
    final leg = Paint()
      ..color = Palette.plateRim
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final legX in [plate.left + plate.width * 0.16,
        plate.right - plate.width * 0.16]) {
      canvas.drawLine(
        Offset(legX, plate.bottom),
        Offset(legX, plate.bottom + metrics.cakeHigh * 0.3),
        leg,
      );
    }
  }

  void _cake(Canvas canvas, Metrics metrics, int at) {
    final rect = metrics.cakeRect(at);
    final round = RRect.fromRectAndRadius(
        rect, Radius.circular(rect.height * 0.46));

    canvas.drawRRect(round, Paint()..color = Palette.cake);

    // The underside, a little darker where it met the iron. Clipped to the
    // cake, or the band's square corners would poke out of the round ones.
    canvas.save();
    canvas.clipRRect(round);
    canvas.drawRect(
      Rect.fromLTRB(
          rect.left, rect.bottom - rect.height * 0.26, rect.right, rect.bottom),
      Paint()..color = Palette.shade,
    );
    canvas.restore();

    canvas.drawRRect(
      round,
      Paint()
        ..color = Palette.crust
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '${play.cakes[at]}',
        style: labels.copyWith(
          color: Palette.brand,
          fontSize: rect.height * 0.52,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      rect.center - Offset(words.width / 2, words.height / 2),
    );
  }

  void _gaps(Canvas canvas, Metrics metrics) {
    // A mark at every boundary whose sizes are not next to each other, the
    // griddle counted as one size bigger than the biggest.
    final many = play.cakes.length;
    for (var at = 0; at < many; at++) {
      final below = at == 0 ? many + 1 : play.cakes[at - 1];
      if ((below - play.cakes[at]).abs() == 1) continue;

      final rect = metrics.cakeRect(at);
      final wider = math.max(
        metrics.wideFor(play.cakes[at]),
        at == 0 ? metrics.widest * 1.06 : metrics.wideFor(play.cakes[at - 1]),
      );
      final y = rect.bottom + 1.5;
      final gap = Paint()
        ..color = Palette.gap
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      // A lightning nick either side of the seam that is wrong.
      for (final side in [-1, 1]) {
        final x = metrics.width / 2 + side * (wider / 2 + 7);
        canvas.drawLine(Offset(x - side * 4, y - 4), Offset(x, y), gap);
        canvas.drawLine(Offset(x, y), Offset(x - side * 4, y + 4), gap);
      }
    }
  }

  void _slice(Canvas canvas, Metrics metrics) {
    final rect = metrics.cakeRect(pointing);
    final y = rect.bottom + 1.5;
    final blade = Paint()
      ..color = Palette.slice
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final from = Offset(rect.left - metrics.cakeHigh * 1.4, y);
    final to = Offset(rect.left + rect.width * 0.42, y);
    canvas.drawLine(from, to, blade);
    // The turn of the handle.
    canvas.drawLine(
      from,
      from + Offset(-metrics.cakeHigh * 0.5, metrics.cakeHigh * 0.42),
      blade,
    );
  }

  @override
  bool shouldRepaint(GriddleView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showGaps != showGaps;
}

/// The words the why speaks, built from where the batch stands, so they are
/// true mid-sort as well as at the start.
String whyWords(Play play) {
  final gaps = play.gapsNow;
  final left = Flips.byWalk(play.cakes);
  if (play.isServed) {
    return 'Served: smallest to biggest, no gaps left. Every flip mended '
        'one.';
  }
  final counting = 'A gap is a pair of neighbours, the griddle counted '
      'under the bottom cake, whose sizes are not next to each other. A '
      'flip moves one seam, so it mends at most one gap.';
  if (gaps == left) {
    return '$counting There are $gaps here, so $gaps more flips at least, '
        'and $gaps is enough.';
  }
  return '$counting There are $gaps here, and the walk of every batch of '
      '${play.cakes.length} says $left flips are needed: a floor holds the '
      'number up without always reaching it. This batch is one where it '
      'falls short.';
}
