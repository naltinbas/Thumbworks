import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../round/play.dart';
import 'palette.dart';

/// Where everything on the map is.
///
/// The painter and the finger both use this, which is the point of it: a
/// place is where it is drawn, and there is no second sum that could disagree
/// with the first.
class Metrics {
  Metrics(this.play, Size room) {
    final side = math.min(room.width, room.height);
    spot = side * 0.036;
    final area = side - spot * 5;
    across = area;
    down = area;
    corner = Offset((room.width - area) / 2, (room.height - area) / 2);
  }

  final Play play;

  late final double spot;
  late final double across;
  late final double down;
  late final Offset corner;

  Offset middleOf(int stop) =>
      corner +
      Offset(play.moor.stops[stop].x * across, play.moor.stops[stop].y * down);

  /// The place under a point, or -1. A finger is allowed to be a good way
  /// off, since these are small marks on a map.
  int stopAt(Offset touch) {
    var nearest = -1;
    var best = spot * 3;
    for (var stop = 0; stop < play.count; stop++) {
      final away = (middleOf(stop) - touch).distance;
      if (away < best) {
        best = away;
        nearest = stop;
      }
    }
    return nearest;
  }
}

/// The map: the places, the road driven so far, and the way home.
class Fen extends CustomPainter {
  const Fen({
    required this.play,
    required this.pointing,
    required this.labels,
  });

  final Play play;

  /// A place the game is pointing at, or -1.
  final int pointing;

  /// The style the names are set in. A painter has no theme to ask.
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final spot = metrics.spot;

    // The road driven, and the way home once the round is finished.
    final road = Paint()
      ..color = Palette.road
      ..strokeWidth = spot * 0.5
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < play.called.length; i++) {
      canvas.drawLine(
        metrics.middleOf(play.called[i - 1]),
        metrics.middleOf(play.called[i]),
        road,
      );
    }
    if (play.isDone) {
      canvas.drawLine(
        metrics.middleOf(play.at),
        metrics.middleOf(0),
        road,
      );
    }

    for (var stop = 0; stop < play.count; stop++) {
      final middle = metrics.middleOf(stop);
      final called = play.hasCalled(stop);
      final colour = stop == 0 ? Palette.yard : Palette.stop;

      canvas.drawCircle(
        middle,
        spot,
        Paint()..color = called ? colour : Palette.ground,
      );
      canvas.drawCircle(
        middle,
        spot,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = spot * 0.3,
      );
      if (stop == pointing) {
        canvas.drawCircle(
          middle,
          spot * 2,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = spot * 0.22,
        );
      }
      if (stop == play.at) {
        canvas.drawCircle(middle, spot * 0.44, Paint()..color = Palette.cart);
      }

      final name = TextPainter(
        text: TextSpan(text: play.moor.stops[stop].name, style: labels),
        textDirection: TextDirection.ltr,
      )..layout();
      name.paint(
        canvas,
        middle + Offset(-name.width / 2, spot * 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(Fen old) =>
      old.play != play || old.pointing != pointing;
}
