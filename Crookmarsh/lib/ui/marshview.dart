import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../marsh/play.dart';
import '../marsh/rules.dart';
import 'palette.dart';

/// Where every crossing lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(Size room) {
    final span = math.min(room.width, room.height) * 0.82;
    cell = span / (Rules.side - 1);
    left = (room.width - span) / 2;
    top = (room.height - span) / 2;
  }

  late final double cell;
  late final double left;
  late final double top;

  /// The point of the crossing at (x, y), y rising from the
  /// bottom.
  Offset crossAt(int x, int y) =>
      Offset(left + x * cell, top + (Rules.side - 1 - y) * cell);

  /// The crossing under a touch, or null for the surrounds.
  (int, int)? crossUnder(Offset touch) {
    for (var x = 0; x < Rules.side; x++) {
      for (var y = 0; y < Rules.side; y++) {
        if ((crossAt(x, y) - touch).distance <= cell * 0.34) {
          return (x, y);
        }
      }
    }
    return null;
  }
}

/// The marsh, drawn.
class MarshView extends CustomPainter {
  MarshView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The crossing being pointed at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// A frame's corners in walking order, so the wash draws as a
  /// quadrilateral and not a bow tie.
  static List<(int, int)> walked(List<(int, int)> frame) {
    double midX = 0;
    double midY = 0;
    for (final (x, y) in frame) {
      midX += x / 4;
      midY += y / 4;
    }
    final ordered = List.of(frame)
      ..sort((a, b) {
        final one = math.atan2(a.$2 - midY, a.$1 - midX);
        final two = math.atan2(b.$2 - midY, b.$1 - midX);
        return one.compareTo(two);
      });
    return ordered;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(size);

    // The reed lines of the marsh.
    for (var at = 0; at < Rules.side; at++) {
      canvas.drawLine(
        metrics.crossAt(at, 0),
        metrics.crossAt(at, Rules.side - 1),
        Paint()
          ..color = Palette.reed
          ..strokeWidth = 1.3,
      );
      canvas.drawLine(
        metrics.crossAt(0, at),
        metrics.crossAt(Rules.side - 1, at),
        Paint()
          ..color = Palette.reed
          ..strokeWidth = 1.3,
      );
    }

    // The crossings.
    for (var x = 0; x < Rules.side; x++) {
      for (var y = 0; y < Rules.side; y++) {
        canvas.drawCircle(
          metrics.crossAt(x, y),
          metrics.cell * 0.05,
          Paint()..color = Palette.cross,
        );
      }
    }

    // Every true frame, washed and ringed in its walking order.
    for (final frame in play.frames) {
      final ring = walked(frame);
      final path = Path()
        ..moveTo(metrics.crossAt(ring[0].$1, ring[0].$2).dx,
            metrics.crossAt(ring[0].$1, ring[0].$2).dy);
      for (final (x, y) in ring.skip(1)) {
        final spot = metrics.crossAt(x, y);
        path.lineTo(spot.dx, spot.dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()..color = Palette.frame.withValues(alpha: 0.12),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.frame
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    // Three posts sharing a line, called out in rust.
    for (final (a, b, c) in play.lined) {
      final ends = [a, b, c]
        ..sort((one, two) => (one.$1 * 10 + one.$2)
            .compareTo(two.$1 * 10 + two.$2));
      canvas.drawLine(
        metrics.crossAt(ends.first.$1, ends.first.$2),
        metrics.crossAt(ends.last.$1, ends.last.$2),
        Paint()
          ..color = Palette.lined
          ..strokeWidth = 3.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointed crossing.
    final pointed = pointing;
    if (pointed != null) {
      canvas.drawCircle(
        metrics.crossAt(pointed.$1, pointed.$2),
        metrics.cell * 0.28,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }

    // The posts, stood on top.
    for (final (x, y) in play.posts) {
      final middle = metrics.crossAt(x, y);
      canvas.drawCircle(
          middle, metrics.cell * 0.14, Paint()..color = Palette.post);
      canvas.drawCircle(
        middle,
        metrics.cell * 0.14,
        Paint()
          ..color = Palette.postRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(MarshView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the marsh at hand.
String whyWords(Play play) {
  final marsh = play.marsh;
  final note = marsh.note == null ? '' : ' ${marsh.note}';
  if (!marsh.winnable) {
    return 'The happy ending theorem holds this marsh: five '
        'posts, none three to a line, always hold four standing '
        'true. Truth is judged two ways that share nothing, the '
        'tuck test and the hull walk, agreeing on every four of '
        'the sweep, and the sweep stood all ${withComma(1668)} '
        'clear fives and found frames in every one.$note';
  }
  return 'A frame is judged two ways that share nothing: the '
      'tuck test looks for a post inside the others\' triangle, '
      'and the hull walk looks for an ordering that bends one '
      'way round. The sweep holds them together on every four '
      'and counts ${withComma(marsh.ways)} clear settings '
      'landing this asking.$note';
}
