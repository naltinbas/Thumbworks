import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../book/play.dart';
import 'palette.dart';

/// Where every hiring lies on the day, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    dayLeft = width * 0.045;
    dayRight = width * 0.955;

    // Stack the hirings into lanes, earliest start first, each into
    // the first lane whose last end lets it in.
    final day = play.day;
    final order = [for (var h = 0; h < day.hirings; h++) h]
      ..sort((one, other) => day.starts[one] != day.starts[other]
          ? day.starts[one].compareTo(day.starts[other])
          : day.ends[one].compareTo(day.ends[other]));
    final laneEnds = <int>[];
    lanes = List<int>.filled(day.hirings, 0);
    for (final hiring in order) {
      var lane = laneEnds.length;
      for (var at = 0; at < laneEnds.length; at++) {
        if (laneEnds[at] <= day.starts[hiring]) {
          lane = at;
          break;
        }
      }
      if (lane == laneEnds.length) laneEnds.add(0);
      laneEnds[lane] = day.ends[hiring];
      lanes[hiring] = lane;
    }
    laneCount = laneEnds.length;
    laneHigh = math.min(height / (laneCount + 2.4), 64.0);
    dayTop = (height - laneCount * laneHigh * 1.16) / 2;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double dayLeft;
  late final double dayRight;
  late final List<int> lanes;
  late final int laneCount;
  late final double laneHigh;
  late final double dayTop;

  static const dayStart = 8;
  static const dayEnd = 20;

  double clockX(num clock) =>
      dayLeft +
      (dayRight - dayLeft) * (clock - dayStart) / (dayEnd - dayStart);

  Rect barRect(int hiring) {
    final day = play.day;
    return Rect.fromLTRB(
      clockX(day.starts[hiring]) + 1.5,
      dayTop + lanes[hiring] * laneHigh * 1.16,
      clockX(day.ends[hiring]) - 1.5,
      dayTop + lanes[hiring] * laneHigh * 1.16 + laneHigh,
    );
  }

  /// The hiring under a touch, or -1.
  int hiringAt(Offset touch) {
    for (var hiring = 0; hiring < play.day.hirings; hiring++) {
      if (barRect(hiring).inflate(2).contains(touch)) return hiring;
    }
    return -1;
  }
}

/// The day, drawn.
class BookView extends CustomPainter {
  BookView({
    required this.play,
    required this.pointing,
    this.strikes = const [],
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The hiring being pointed at, or -1.
  final int pointing;

  /// The piercing o'clocks to strike in gold, when asked.
  final List<int> strikes;

  /// Whether names and hours may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final clashing = <int>{};
    for (final (one, other) in play.clashes) {
      clashing.add(one);
      clashing.add(other);
    }

    // The hours, ticked along the bottom.
    final floorY =
        metrics.dayTop + metrics.laneCount * metrics.laneHigh * 1.16 +
            metrics.laneHigh * 0.3;
    canvas.drawLine(
      Offset(metrics.dayLeft, floorY),
      Offset(metrics.dayRight, floorY),
      Paint()
        ..color = Palette.line
        ..strokeWidth = 1.6,
    );
    for (var clock = Metrics.dayStart; clock <= Metrics.dayEnd;
        clock += 2) {
      final x = metrics.clockX(clock);
      canvas.drawLine(
        Offset(x, floorY - 4),
        Offset(x, floorY + 4),
        Paint()
          ..color = Palette.line
          ..strokeWidth = 1.6,
      );
      if (!showWords) continue;
      final words = TextPainter(
        text: TextSpan(
          text: '$clock',
          style: labels.copyWith(
            color: Palette.inkDim,
            fontSize: metrics.laneHigh * 0.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(canvas,
          Offset(x - words.width / 2, floorY + metrics.laneHigh * 0.14));
    }

    for (final strike in strikes) {
      final x = metrics.clockX(strike - 0.5);
      var y = metrics.dayTop - metrics.laneHigh * 0.3;
      final bottom = floorY;
      final dash = metrics.laneHigh * 0.28;
      final paint = Paint()
        ..color = Palette.strike
        ..strokeWidth = 2.2;
      while (y < bottom) {
        canvas.drawLine(
            Offset(x, y), Offset(x, math.min(y + dash, bottom)), paint);
        y += dash * 1.8;
      }
    }

    for (var hiring = 0; hiring < play.day.hirings; hiring++) {
      _bar(canvas, metrics, hiring, clashing.contains(hiring));
    }
  }

  void _bar(Canvas canvas, Metrics metrics, int hiring, bool clashes) {
    final rect = metrics.barRect(hiring);
    final booked = play.isBooked(hiring);
    final round = Radius.circular(metrics.laneHigh * 0.24);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, round),
      Paint()..color = booked ? Palette.bookedBar : Palette.bar,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, round),
      Paint()
        ..color = hiring == pointing
            ? Palette.shown
            : clashes
                ? Palette.clash
                : booked
                    ? Palette.bookedEdge
                    : Palette.barEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            hiring == pointing || clashes ? 2.6 : 1.4,
    );

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: play.day.guests[hiring],
        style: labels.copyWith(
          color: booked ? Palette.ink : Palette.inkDim,
          fontSize: metrics.laneHigh * 0.26,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      ellipsis: '…',
      maxLines: 1,
    )..layout(maxWidth: math.max(rect.width - 8, 12));
    words.paint(
      canvas,
      Offset(rect.left + 4,
          rect.center.dy - words.height / 2),
    );
  }

  @override
  bool shouldRepaint(BookView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.strikes != strikes;
}

/// The words the why speaks, from the day at hand.
String whyWords(Play play) {
  final day = play.day;
  final note = day.note == null ? '' : ' ${day.note}';
  final strikes = play.rules.piercing();
  final struck = strikes.map((strike) => '$strike').join(', ');
  if (!day.winnable) {
    return 'The gold o\'clocks, struck just before $struck, pierce '
        'every hiring: each holds one, and two guests holding the '
        'same o\'clock clash. A book of ${day.ask} would need '
        '${day.ask} different o\'clocks, and there are only '
        '${strikes.length}.$note';
  }
  return 'The sweep tried every choice of hirings and none holds '
      'more than ${day.fullest}. The gold o\'clocks say why no more '
      'can: every hiring holds one, and two guests holding the same '
      'o\'clock clash, so ${strikes.length} is the ceiling. Booking '
      'whatever finishes earliest reaches it.$note';
}
