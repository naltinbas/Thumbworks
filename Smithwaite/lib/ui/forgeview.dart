import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../forge/play.dart';
import 'palette.dart';

/// Where everything hangs, shared by the painter and the hit-testing, so
/// where a ring is drawn is exactly where a ring is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;

    final rings = play.puzzle.rings;
    colWide = math.min(width / (rings + 0.6), height * 0.3);
    across = colWide * rings;
    left = (width - across) / 2;
    radius = math.min(colWide * 0.34, height * 0.1);
    barY = math.max(radius * 3.4, height * 0.30);
    drop = radius * 2.1;
    // The plate hangs just under the dropped rings, not at the bottom of
    // whatever room the phone has spare.
    plateY = math.min(height - radius * 0.6, barY + drop + radius * 2.4);
  }

  final Play play;

  late final double width;
  late final double height;
  late final double colWide;
  late final double across;
  late final double left;

  /// Where the bar runs.
  late final double barY;

  /// Where the plate lies.
  late final double plateY;

  /// A ring's size, and how far an off ring hangs below the bar.
  late final double radius;
  late final double drop;

  /// The middle of a ring's column. The far ring is drawn leftmost and the
  /// hand ring rightmost, the way the toy is held.
  double middleOf(int ring) =>
      left + (play.puzzle.rings - 1 - ring + 0.5) * colWide;

  /// Where a ring's circle is centred as it lies.
  Offset ringAt(int ring) => Offset(
        middleOf(ring),
        play.isOn(ring) ? barY : barY + drop,
      );

  /// The ring under a touch, by its column, or -1 for nowhere.
  int ringUnder(Offset touch) {
    if (touch.dy < barY - radius * 2.2 || touch.dy > plateY) return -1;
    final column = ((touch.dx - left) / colWide).floor();
    if (column < 0 || column >= play.puzzle.rings) return -1;
    return play.puzzle.rings - 1 - column;
  }
}

/// The toy, drawn.
class ForgeView extends CustomPainter {
  ForgeView({
    required this.play,
    required this.pointing,
    required this.showCount,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The ring being pointed at, or -1.
  final int pointing;

  /// Whether to write the smith's figures over the rings.
  final bool showCount;

  /// Whether figures may be written at all. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    _plate(canvas, metrics);
    _cords(canvas, metrics);
    _bar(canvas, metrics);
    for (var ring = 0; ring < play.puzzle.rings; ring++) {
      _ring(canvas, metrics, ring);
    }
    if (showCount && showWords) _figures(canvas, metrics);
    if (pointing >= 0) _point(canvas, metrics);
  }

  void _plate(Canvas canvas, Metrics metrics) {
    final plank = Rect.fromLTWH(
      metrics.left - metrics.colWide * 0.2,
      metrics.plateY,
      metrics.across + metrics.colWide * 0.4,
      math.max(5.0, metrics.radius * 0.4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(plank, Radius.circular(plank.height * 0.4)),
      Paint()..color = Palette.plate,
    );
  }

  void _cords(Canvas canvas, Metrics metrics) {
    final cord = Paint()
      ..color = Palette.cord
      ..strokeWidth = math.max(1.6, metrics.radius * 0.12);
    for (var ring = 0; ring < play.puzzle.rings; ring++) {
      final hang = metrics.ringAt(ring);
      canvas.drawLine(
        Offset(hang.dx, metrics.plateY),
        hang + Offset(0, metrics.radius * 0.7),
        cord,
      );
    }
  }

  void _bar(Canvas canvas, Metrics metrics) {
    final barHigh = math.max(4.0, metrics.radius * 0.34);
    final bar = Rect.fromLTWH(
      metrics.left - metrics.colWide * 0.34,
      metrics.barY - barHigh / 2,
      metrics.across + metrics.colWide * 0.5,
      barHigh,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, Radius.circular(barHigh / 2)),
      Paint()..color = Palette.bar,
    );
    canvas.drawLine(
      Offset(bar.left + 2, bar.bottom - 1),
      Offset(bar.right - 2, bar.bottom - 1),
      Paint()
        ..color = Palette.barDark
        ..strokeWidth = 1.4,
    );
    // The handle loop at the hand end, kept inside the canvas.
    canvas.drawCircle(
      Offset(
        math.min(bar.right + metrics.radius * 0.5,
            metrics.width - metrics.radius * 0.62),
        metrics.barY,
      ),
      metrics.radius * 0.5,
      Paint()
        ..color = Palette.bar
        ..style = PaintingStyle.stroke
        ..strokeWidth = barHigh * 0.7,
    );
  }

  void _ring(Canvas canvas, Metrics metrics, int ring) {
    final middle = metrics.ringAt(ring);
    final holds = Paint()
      ..color = play.mayMove(ring) ? Palette.ring : Palette.ringHeld
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3.0, metrics.radius * 0.26);
    canvas.drawCircle(middle, metrics.radius, holds);
  }

  void _figures(Canvas canvas, Metrics metrics) {
    // The smith's figures: over the far ring, 1 if it is on; walking
    // toward the hand, flip at every ring that is on, copy at every ring
    // that is off. Together they are the count in binary.
    var figure = 0;
    for (var ring = play.puzzle.rings - 1; ring >= 0; ring--) {
      if (play.isOn(ring)) figure = 1 - figure;
      final words = TextPainter(
        text: TextSpan(
          text: '$figure',
          style: labels.copyWith(
            color: Palette.figure,
            fontSize: metrics.radius * 1.05,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        Offset(
          metrics.middleOf(ring) - words.width / 2,
          metrics.barY - metrics.radius * 2.9,
        ),
      );
    }
  }

  void _point(Canvas canvas, Metrics metrics) {
    canvas.drawCircle(
      metrics.ringAt(pointing),
      metrics.radius * 1.45,
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(ForgeView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showCount != showCount;
}
