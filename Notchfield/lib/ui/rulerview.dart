import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ruler/play.dart';
import 'palette.dart';

/// Where the rule and its census lie, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    left = width * 0.06;
    right = width * 0.94;
    ruleY = height * 0.30;
    step = (right - left) / play.cut.length;
    chip = math.min(step * 0.42, width * 0.038);
    censusY = height * 0.62;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double left;
  late final double right;
  late final double ruleY;
  late final double step;
  late final double chip;
  late final double censusY;

  double markX(int mark) => left + mark * step;

  Offset chipCenter(int distance) {
    final length = play.cut.length;
    final perRow = (length / 2).ceil();
    final row = (distance - 1) ~/ perRow;
    final at = (distance - 1) % perRow;
    final rowWide = perRow * chip * 2.5;
    final start = (width - rowWide) / 2 + chip * 1.25;
    return Offset(
        start + at * chip * 2.5, censusY + row * chip * 3.2);
  }

  /// The mark under a touch, or -1.
  int markAt(Offset touch) {
    if ((touch.dy - ruleY).abs() > step * 1.4 &&
        (touch.dy - ruleY).abs() > 44) {
      return -1;
    }
    final mark = ((touch.dx - left) / step).round();
    if (mark < 0 || mark > play.cut.length) return -1;
    if ((touch.dx - markX(mark)).abs() > step * 0.5) return -1;
    return mark;
  }
}

/// The rule, drawn.
class RulerView extends CustomPainter {
  RulerView({
    required this.play,
    required this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The mark being pointed at, or -1.
  final int pointing;

  /// Whether numbers may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The rule bar.
    final bar = Rect.fromLTRB(
      metrics.left - metrics.step * 0.2,
      metrics.ruleY - metrics.step * 0.34,
      metrics.right + metrics.step * 0.2,
      metrics.ruleY + metrics.step * 0.34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, Radius.circular(metrics.step * 0.16)),
      Paint()..color = Palette.rule,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, Radius.circular(metrics.step * 0.16)),
      Paint()
        ..color = Palette.ruleEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // The marks, and the notches cut.
    for (var mark = 0; mark <= play.cut.length; mark++) {
      final x = metrics.markX(mark);
      canvas.drawLine(
        Offset(x, bar.top),
        Offset(x, bar.top + metrics.step * 0.16),
        Paint()
          ..color = Palette.ruleEdge
          ..strokeWidth = 1.4,
      );
      if (play.hasNotch(mark)) {
        final wedge = Path()
          ..moveTo(x - metrics.step * 0.2, bar.bottom)
          ..lineTo(x + metrics.step * 0.2, bar.bottom)
          ..lineTo(x, bar.top + metrics.step * 0.14)
          ..close();
        canvas.drawPath(wedge, Paint()..color = Palette.notch);
        canvas.drawPath(
          wedge,
          Paint()
            ..color = Palette.notchEdge
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
      if (mark == pointing) {
        canvas.drawCircle(
          Offset(x, bar.center.dy),
          metrics.step * 0.42,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      }
      if (showWords && (mark % 2 == 0 || play.cut.length <= 6)) {
        final words = TextPainter(
          text: TextSpan(
            text: '$mark',
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: math.min(metrics.step * 0.34, 13.0),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(canvas,
            Offset(x - words.width / 2, bar.bottom + metrics.step * 0.22));
      }
    }

    // The census: one chip per length.
    final counts = play.census;
    for (var distance = 1; distance <= play.cut.length; distance++) {
      final middle = metrics.chipCenter(distance);
      final count = counts[distance];
      final colour = count == 0
          ? Palette.unmeasured
          : count == 1
              ? Palette.once
              : Palette.twice;
      canvas.drawCircle(middle, metrics.chip,
          Paint()..color = colour.withValues(alpha: 0.22));
      canvas.drawCircle(
        middle,
        metrics.chip,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = count > 1 ? 2.4 : 1.6,
      );
      if (!showWords) continue;
      final words = TextPainter(
        text: TextSpan(
          text: '$distance',
          style: labels.copyWith(
            color: colour,
            fontSize: metrics.chip * 0.95,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
          canvas, middle - Offset(words.width / 2, words.height / 2));
    }
  }

  @override
  bool shouldRepaint(RulerView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the ruler at hand.
String whyWords(Play play) {
  final cut = play.cut;
  final note = cut.note == null ? '' : ' ${cut.note}';
  if (!cut.winnable) {
    return 'The sweep placed ${cut.notches} notches every way a '
        '${cut.length}-length allows and read every census: a '
        'repeated length every time.$note';
  }
  final ask = cut.perfect
      ? 'every length from one to ${cut.length} measured exactly once'
      : 'no length measured twice';
  return 'The ask is $ask, and the census under the rule is the '
      'whole truth of the cutting so far: green once, grey unmeasured, '
      'red doubled. The sweep counted ${cut.ways} '
      'cutting${cut.ways == 1 ? '' : 's'} meeting the ask.$note';
}
