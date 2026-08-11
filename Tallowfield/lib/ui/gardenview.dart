import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../garden/code.dart';
import '../garden/play.dart';
import 'palette.dart';

/// Where everything stands, shared by the painter and the hit-testing, so
/// where a lantern is drawn is exactly where a lantern is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    middle = Offset(width / 2, height / 2 + height * 0.02);
    round = math.min(width, height) * 0.30;
    spread = round * 0.62;
    lamp = round * 0.17;
  }

  final Play play;

  late final double width;
  late final double height;
  late final Offset middle;

  /// A hedge's radius, how far the hedge middles stand from the garden's,
  /// and a lantern's size.
  late final double round;
  late final double spread;
  late final double lamp;

  /// The three hedge middles: A above, B down left, C down right.
  Offset hedgeMiddle(int hedge) {
    final turn = -math.pi / 2 + hedge * 2 * math.pi / 3;
    return middle + Offset(math.cos(turn), math.sin(turn)) * spread;
  }

  /// Where a lantern stands: the middle of its bed, worked out from the
  /// hedges that hold it.
  Offset lampAt(int number) {
    var pull = Offset.zero;
    var holds = 0;
    for (var hedge = 0; hedge < 3; hedge++) {
      if (Code.inHedge(number, hedge)) {
        pull += hedgeMiddle(hedge) - middle;
        holds++;
      }
    }
    if (holds == 3) return middle;
    if (holds == 2) return middle + pull * 0.55;
    return middle + pull * 1.72;
  }

  /// The lantern under a touch, or -1 for nowhere.
  int lampUnder(Offset touch) {
    for (var number = 1; number <= 7; number++) {
      if ((lampAt(number) - touch).distance <= lamp * 1.6) return number;
    }
    return -1;
  }
}

/// The garden, drawn.
class GardenView extends CustomPainter {
  GardenView({
    required this.play,
    required this.pointing,
    required this.showBeds,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The lantern being pointed at, or -1.
  final int pointing;

  /// Whether to shade the named bed when a hedge complains.
  final bool showBeds;

  /// Whether tallies may write words. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  static const hedgeColours = [Palette.hedgeA, Palette.hedgeB, Palette.hedgeC];

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final complaints = play.complaints;

    for (var hedge = 0; hedge < 3; hedge++) {
      canvas.drawCircle(
        metrics.hedgeMiddle(hedge),
        metrics.round,
        Paint()..color = hedgeColours[hedge].withValues(alpha: 0.16),
      );
      canvas.drawCircle(
        metrics.hedgeMiddle(hedge),
        metrics.round,
        Paint()
          ..color =
              complaints[hedge] ? Palette.complaint : hedgeColours[hedge]
          ..style = PaintingStyle.stroke
          ..strokeWidth = complaints[hedge] ? 3.0 : 1.8,
      );
    }

    if (showBeds && play.named != 0) _bed(canvas, metrics);
    for (var number = 1; number <= 7; number++) {
      _lantern(canvas, metrics, number);
    }
    if (showWords) _tallies(canvas, metrics, complaints);
    if (pointing >= 1) _point(canvas, metrics);
  }

  void _bed(Canvas canvas, Metrics metrics) {
    canvas.drawCircle(
      metrics.lampAt(play.named),
      metrics.lamp * 2.1,
      Paint()..color = Palette.complaint.withValues(alpha: 0.22),
    );
  }

  void _lantern(Canvas canvas, Metrics metrics, int number) {
    final where = metrics.lampAt(number);
    final isLit = play.lit(number);

    if (isLit) {
      canvas.drawCircle(where, metrics.lamp * 2.0, Paint()..color = Palette.glow);
    }

    // The case: a squat lantern with a little cap.
    final body = Rect.fromCenter(
      center: where + Offset(0, metrics.lamp * 0.12),
      width: metrics.lamp * 1.28,
      height: metrics.lamp * 1.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(metrics.lamp * 0.3)),
      Paint()..color = Palette.lantern,
    );
    canvas.drawLine(
      body.topCenter + Offset(0, -metrics.lamp * 0.26),
      body.topCenter,
      Paint()
        ..color = Palette.lantern
        ..strokeWidth = metrics.lamp * 0.4,
    );

    // The pane, flame or dark.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        body.deflate(metrics.lamp * 0.22),
        Radius.circular(metrics.lamp * 0.18),
      ),
      Paint()..color = isLit ? Palette.flame : Palette.dark,
    );
  }

  void _tallies(Canvas canvas, Metrics metrics, List<bool> complaints) {
    const names = ['A', 'B', 'C'];
    for (var hedge = 0; hedge < 3; hedge++) {
      final out = metrics.hedgeMiddle(hedge) - metrics.middle;
      final way = out / out.distance;
      final at = metrics.hedgeMiddle(hedge) +
          way * (metrics.round + metrics.lamp * 1.4);

      final words = TextPainter(
        text: TextSpan(
          text: '${names[hedge]} ${complaints[hedge] ? 'odd' : 'even'}',
          style: labels.copyWith(
            color: complaints[hedge] ? Palette.complaint : Palette.inkDim,
            fontSize: metrics.lamp * 0.9,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Kept inside the canvas, or the side tallies lose their letters.
      final x = (at.dx - words.width / 2)
          .clamp(4.0, metrics.width - words.width - 4.0);
      words.paint(canvas, Offset(x, at.dy - words.height / 2));
    }
  }

  void _point(Canvas canvas, Metrics metrics) {
    canvas.drawCircle(
      metrics.lampAt(pointing),
      metrics.lamp * 2.0,
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(GardenView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showBeds != showBeds;
}

/// The words the why speaks, from the evening at hand.
String whyWords(Play play) {
  final odd = play.complaints;
  final which = [
    for (var hedge = 0; hedge < 3; hedge++)
      if (odd[hedge]) 'ABC'[hedge],
  ].join(' and ');
  final start = 'The gardener lights the lanterns so every hedge holds an '
      'even count. A changed lantern turns exactly its own hedges odd, so '
      'the complaining hedges cut out one bed among seven, and the bed '
      'names the lantern.';
  final tonight = play.named == 0
      ? ' Tonight no hedge complains.'
      : ' Tonight $which complain${which.length == 1 ? 's' : ''}: the bed '
          'inside ${which.isEmpty ? '' : which} and no other, which is '
          'lamp ${play.named}.';
  final note = play.evening.note;
  return '$start$tonight${note == null ? '' : ' $note'}';
}
