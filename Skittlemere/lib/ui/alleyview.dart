import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../alley/play.dart';
import '../alley/rules.dart';
import 'palette.dart';

/// Where every skittle stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final rows = play.frame.rows;
    final widest = rows.reduce(math.max);
    lane = math.min(width * 0.9 / widest, 64.0);
    pin = lane * 0.36;
    rowGap = math.min(height / (rows.length + 1.6), lane * 2.2);
    top = (height - rows.length * rowGap) / 2 + rowGap * 0.5;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double lane;
  late final double pin;
  late final double rowGap;
  late final double top;

  Offset pinCenter(int row, int at) {
    final count = play.frame.rows[row];
    final left = (width - count * lane) / 2 + lane / 2;
    return Offset(left + at * lane, top + row * rowGap);
  }

  /// The skittle under a touch, or null.
  (int, int)? pinAt(Offset touch) {
    for (var row = 0; row < play.frame.rows.length; row++) {
      for (var at = 0; at < play.frame.rows[row]; at++) {
        if ((pinCenter(row, at) - touch).distance <= lane * 0.48) {
          return (row, at);
        }
      }
    }
    return null;
  }
}

/// The alley, drawn.
class AlleyView extends CustomPainter {
  AlleyView({
    required this.play,
    this.armed,
    this.pointing,
    this.showCounts = false,
    required this.labels,
  });

  final Play play;

  /// The skittle armed for a knock, or null.
  final (int, int)? armed;

  /// The knock being pointed at, or null: row, pin, second pin or -1.
  final (int, int, int)? pointing;

  /// Whether to chip each standing run with its count.
  final bool showCounts;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var row = 0; row < play.frame.rows.length; row++) {
      for (var at = 0; at < play.frame.rows[row]; at++) {
        _skittle(canvas, metrics, row, at);
      }
    }

    if (showCounts) _counts(canvas, metrics);
  }

  void _skittle(Canvas canvas, Metrics metrics, int row, int at) {
    final middle = metrics.pinCenter(row, at);
    final pin = metrics.pin;
    final stands = play.stands(row, at);

    if (!stands) {
      // A felled stub, lying flat.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: middle + Offset(0, pin * 0.9),
              width: pin * 1.7,
              height: pin * 0.55),
          Radius.circular(pin * 0.27),
        ),
        Paint()..color = Palette.felled,
      );
      return;
    }

    // The body, the band, and the head.
    final body = Path()
      ..moveTo(middle.dx - pin * 0.55, middle.dy + pin * 1.15)
      ..quadraticBezierTo(middle.dx - pin * 0.75, middle.dy - pin * 0.1,
          middle.dx - pin * 0.28, middle.dy - pin * 0.55)
      ..lineTo(middle.dx + pin * 0.28, middle.dy - pin * 0.55)
      ..quadraticBezierTo(middle.dx + pin * 0.75, middle.dy - pin * 0.1,
          middle.dx + pin * 0.55, middle.dy + pin * 1.15)
      ..close();
    canvas.drawPath(body, Paint()..color = Palette.skittle);
    canvas.drawRect(
      Rect.fromCenter(
          center: middle + Offset(0, -pin * 0.1),
          width: pin * 1.16,
          height: pin * 0.3),
      Paint()..color = Palette.skittleBand,
    );
    canvas.drawCircle(middle + Offset(0, -pin * 0.95), pin * 0.42,
        Paint()..color = Palette.skittle);

    final armedHere =
        armed != null && armed!.$1 == row && armed!.$2 == at;
    final pointed = pointing;
    final pointedHere = pointed != null &&
        pointed.$1 == row &&
        (pointed.$2 == at || pointed.$3 == at);
    if (armedHere || pointedHere) {
      canvas.drawCircle(
        middle,
        pin * 1.5,
        Paint()
          ..color = armedHere ? Palette.armed : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
  }

  void _counts(Canvas canvas, Metrics metrics) {
    for (var row = 0; row < play.frame.rows.length; row++) {
      var at = 0;
      while (at < play.frame.rows[row]) {
        if (!play.stands(row, at)) {
          at++;
          continue;
        }
        var end = at;
        while (
            end + 1 < play.frame.rows[row] && play.stands(row, end + 1)) {
          end++;
        }
        final run = end - at + 1;
        final middle = Offset(
          (metrics.pinCenter(row, at).dx +
                  metrics.pinCenter(row, end).dx) /
              2,
          metrics.pinCenter(row, at).dy + metrics.pin * 2.2,
        );
        final words = TextPainter(
          text: TextSpan(
            text: '${Rules.countOf(run)}',
            style: labels.copyWith(
              color: Palette.countChip,
              fontSize: metrics.pin * 0.95,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(canvas,
            middle - Offset(words.width / 2, words.height / 2));
        at = end + 1;
      }
    }
  }

  @override
  bool shouldRepaint(AlleyView old) =>
      old.play != play ||
      old.armed != armed ||
      old.pointing != pointing ||
      old.showCounts != showCounts;
}

/// The words the why speaks, from the alley at hand.
String whyWords(Play play) {
  final frame = play.frame;
  final note = frame.note == null ? '' : ' ${frame.note}';
  final counts = play.segments.map(Rules.countOf).join(', ');
  if (!frame.winnable) {
    return 'Each standing run has a count, and the alley adds them '
        'the carry-less way: here that comes to nought, and from '
        'nought every knock hands the other side a count to zero '
        'again. The search of every position of fourteen or fewer '
        'says the same with no arithmetic at all.$note';
  }
  return 'Each standing run has a count, gold under it: $counts, and '
      'added the carry-less way the alley stands at ${play.count}. '
      'Zero it with your knock and the house inherits nothing; the '
      'search of every position agrees with the arithmetic '
      'everywhere it can reach.$note';
}
