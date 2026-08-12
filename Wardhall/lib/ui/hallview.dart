import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hall/play.dart';
import '../hall/rules.dart';
import 'palette.dart';

/// Where the hall and its flags lie, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    var lowX = play.hall.corners.first.$1;
    var highX = lowX;
    var lowY = play.hall.corners.first.$2;
    var highY = lowY;
    for (final (x, y) in play.hall.corners) {
      lowX = math.min(lowX, x);
      highX = math.max(highX, x);
      lowY = math.min(lowY, y);
      highY = math.max(highY, y);
    }
    _lowX = lowX;
    scale = math.min(
      room.width * 0.86 / (highX - lowX),
      room.height * 0.86 / (highY - lowY),
    );
    left = (room.width - scale * (highX - lowX)) / 2;
    top = (room.height - scale * (highY - lowY)) * 0.46;
    _highY = highY;
  }

  final Play play;

  late final double scale;
  late final double left;
  late final double top;
  late final int _lowX;
  late final int _highY;

  /// A hall point on the canvas, north up.
  Offset at((int, int) spot) => Offset(
        left + scale * (spot.$1 - _lowX),
        top + scale * (_highY - spot.$2),
      );

  /// The corner under a touch, or null: its index.
  int? cornerUnder(Offset touch) {
    for (var at = 0; at < play.hall.corners.length; at++) {
      if ((this.at(play.hall.corners[at]) - touch).distance <=
          scale * 0.42) {
        return at;
      }
    }
    return null;
  }
}

/// The hall, drawn.
class HallView extends CustomPainter {
  HallView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The corner being pointed at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final corners = play.hall.corners;

    // The floor first, flag by flag.
    final unlit = play.unlit.toSet();
    for (final flag in Rules.floorOf(corners)) {
      final spot = metrics.at(flag);
      final dark = unlit.contains(flag);
      final reach = metrics.scale * (dark ? 0.13 : 0.16);
      final diamond = Path()
        ..moveTo(spot.dx, spot.dy - reach)
        ..lineTo(spot.dx + reach, spot.dy)
        ..lineTo(spot.dx, spot.dy + reach)
        ..lineTo(spot.dx - reach, spot.dy)
        ..close();
      canvas.drawPath(
        diamond,
        Paint()..color = dark ? Palette.dark : Palette.litDim,
      );
      if (!dark) {
        canvas.drawPath(
          diamond,
          Paint()
            ..color = Palette.lit.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }

    // The walls.
    final walls = Path()
      ..moveTo(metrics.at(corners.first).dx,
          metrics.at(corners.first).dy);
    for (final corner in corners.skip(1)) {
      final spot = metrics.at(corner);
      walls.lineTo(spot.dx, spot.dy);
    }
    walls.close();
    canvas.drawPath(
      walls,
      Paint()
        ..color = Palette.wall
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(metrics.scale * 0.14, 3.0)
        ..strokeJoin = StrokeJoin.round,
    );

    // The corners, warded ones carrying lanterns.
    for (var at = 0; at < corners.length; at++) {
      final spot = metrics.at(corners[at]);
      final warded = play.wards.contains(at);
      if (at == pointing) {
        canvas.drawCircle(
          spot,
          metrics.scale * 0.4,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
      if (warded) {
        canvas.drawCircle(
          spot,
          metrics.scale * 0.5,
          Paint()
            ..color = Palette.lantern.withValues(alpha: 0.16),
        );
        canvas.drawCircle(spot, metrics.scale * 0.24,
            Paint()..color = Palette.lantern);
        canvas.drawCircle(
          spot,
          metrics.scale * 0.24,
          Paint()
            ..color = Palette.lit
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      } else {
        canvas.drawCircle(spot, metrics.scale * 0.15,
            Paint()..color = Palette.corner);
      }
    }
  }

  @override
  bool shouldRepaint(HallView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the hall at hand.
String whyWords(Play play) {
  final hall = play.hall;
  final note = hall.note == null ? '' : ' ${hall.note}';
  final watch = Rules.fiskWatch(hall.corners).length;
  final corners = hall.corners.length;
  if (!hall.winnable) {
    return 'The sweep posts every set of corners there is, and no '
        '${hall.asked} of these $corners light the whole floor: '
        'the fewest is ${hall.fewest}. The three-colouring, which '
        'never counts a flag, still posts a working watch of '
        '$watch, a third of the corners or fewer, and even it '
        'cannot get under the sweep.$note';
  }
  return 'Cut the hall into triangles and colour the corners three '
      'ways so no triangle repeats one: the scarcest colour is a '
      'watch that lights everything, $watch of $corners corners '
      'here, never more than a third. The sweep posts every set '
      'and finds the true fewest, ${hall.fewest}: the colouring is '
      'a roof over it.$note';
}
