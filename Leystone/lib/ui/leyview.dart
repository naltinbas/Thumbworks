import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ley/play.dart';
import 'palette.dart';

/// Where every berth lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final size = play.green.size;
    final span = math.min(room.width, room.height) * 0.86;
    cell = span / (size - 1 + 1.0);
    left = (room.width - cell * (size - 1)) / 2;
    top = (room.height - cell * (size - 1)) * 0.44;
  }

  final Play play;

  late final double cell;
  late final double left;
  late final double top;

  /// The point of the berth at (x, y), y rising from the bottom.
  Offset berthAt(int x, int y) => Offset(
        left + x * cell,
        top + (play.green.size - 1 - y) * cell,
      );

  /// The berth under a touch, or null for the surrounds.
  (int, int)? berthUnder(Offset touch) {
    for (var x = 0; x < play.green.size; x++) {
      for (var y = 0; y < play.green.size; y++) {
        if ((berthAt(x, y) - touch).distance <= cell * 0.4) {
          return (x, y);
        }
      }
    }
    return null;
  }
}

/// The green, drawn.
class LeyView extends CustomPainter {
  LeyView({
    required this.play,
    this.pointing,
    this.ley,
    required this.labels,
  });

  final Play play;

  /// The berth being pointed at, or null.
  final (int, int)? pointing;

  /// A refused stone: the pair it would ley with, and its berth.
  final (((int, int), (int, int)), (int, int))? ley;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final green = play.green;

    // The berths.
    for (var x = 0; x < green.size; x++) {
      for (var y = 0; y < green.size; y++) {
        canvas.drawCircle(
          metrics.berthAt(x, y),
          metrics.cell * 0.055,
          Paint()..color = Palette.berth,
        );
      }
    }

    // The ley a refused stone would stand on, drawn across the
    // whole green.
    final refused = ley;
    if (refused != null) {
      final ((a, b), berth) = refused;
      _leyLine(canvas, metrics, size, a, b);
      _menhir(canvas, metrics, berth,
          ghost: true, done: false);
    }

    // The pointed berth.
    final pointed = pointing;
    if (pointed != null) {
      canvas.drawCircle(
        metrics.berthAt(pointed.$1, pointed.$2),
        metrics.cell * 0.3,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }

    // The stones.
    for (final stone in play.stones) {
      _menhir(canvas, metrics, stone,
          ghost: false, done: play.isDone);
    }
  }

  void _leyLine(Canvas canvas, Metrics metrics, Size size,
      (int, int) a, (int, int) b) {
    final from = metrics.berthAt(a.$1, a.$2);
    final to = metrics.berthAt(b.$1, b.$2);
    final way = (to - from) / (to - from).distance;
    // Stretch the line well past both stones, clipped by the canvas.
    final long = size.width + size.height;
    final start = from - way * long;
    final end = from + way * long;
    var at = 0.0;
    final whole = (end - start).distance;
    final dash = metrics.cell * 0.22;
    final paint = Paint()
      ..color = Palette.ley
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final step = (end - start) / whole;
    while (at < whole) {
      final stop = math.min(at + dash, whole);
      canvas.drawLine(
          start + step * at, start + step * stop, paint);
      at = stop + dash * 0.9;
    }
  }

  void _menhir(Canvas canvas, Metrics metrics, (int, int) berth,
      {required bool ghost, required bool done}) {
    final stand = metrics.berthAt(berth.$1, berth.$2);
    final wide = metrics.cell * 0.34;
    final tall = metrics.cell * 0.62;
    final shape = Path()
      ..moveTo(stand.dx - wide * 0.5, stand.dy + tall * 0.18)
      ..lineTo(stand.dx - wide * 0.42, stand.dy - tall * 0.62)
      ..quadraticBezierTo(
          stand.dx - wide * 0.18,
          stand.dy - tall * 0.86,
          stand.dx + wide * 0.16,
          stand.dy - tall * 0.8)
      ..quadraticBezierTo(
          stand.dx + wide * 0.46,
          stand.dy - tall * 0.72,
          stand.dx + wide * 0.5,
          stand.dy - tall * 0.4)
      ..lineTo(stand.dx + wide * 0.44, stand.dy + tall * 0.18)
      ..close();

    if (ghost) {
      canvas.drawPath(
        shape,
        Paint()
          ..color = Palette.ley
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      return;
    }

    canvas.drawPath(shape, Paint()..color = Palette.stone);
    canvas.drawPath(
      shape,
      Paint()
        ..color = done ? Palette.done : Palette.stoneDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = done ? 2.6 : 1.4,
    );
    // A lichen fleck.
    canvas.drawCircle(
      stand.translate(wide * 0.14, -tall * 0.34),
      wide * 0.12,
      Paint()..color = Palette.lichen,
    );
  }

  @override
  bool shouldRepaint(LeyView old) =>
      old.play != play || old.pointing != pointing || old.ley != ley;
}

/// The words the why speaks, from the green at hand.
String whyWords(Play play) {
  final green = play.green;
  final note = green.note == null ? '' : ' ${green.note}';
  if (!green.winnable) {
    return 'Lay seven stones on three rows and some row holds '
        'three, by plain counting, and a row is a straight line: a '
        'ley before any slant is even looked at. The search says '
        'the same from the other side, trying every laying-out of '
        'seven berths, all 36 of them, and finding a ley in each. '
        'Six is this green\'s roof, and the sixth is as far as '
        'anyone gets.$note';
  }
  return 'A ley is any straight line through three stones, on any '
      'slope the green knows, and a green of ${green.size} rows '
      'holds two stones a row at most: that counting roofs the ring '
      'at ${green.asked}. The search raises every sound ring there '
      'is and finds ${green.ways} of ${green.asked}, so the roof '
      'is stood on.$note';
}
