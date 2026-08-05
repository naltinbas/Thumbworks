import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../chase/chart.dart';
import '../chase/play.dart';
import 'palette.dart';

/// Where everything on the map is.
///
/// The painter and the finger both use this, which is the point of it: a
/// place is where it is drawn, and there is no second sum that could
/// disagree with the first.
class Metrics {
  Metrics(this.chart, Size room) {
    // A square, in the middle of whatever room there is. The places are
    // written down as fractions of a square map, and stretching that to fill
    // a phone would push the ones along a lane into each other and leave the
    // ones up a hill miles apart.
    final side = math.min(room.width, room.height);
    spot = side * 0.055;
    final area = side - spot * 2.6;
    across = area;
    down = area;
    corner = Offset((room.width - area) / 2, (room.height - area) / 2);
  }

  final Chart chart;

  /// How big a place is drawn.
  late final double spot;

  late final double across;
  late final double down;
  late final Offset corner;

  Offset middleOf(int place) =>
      corner +
      Offset(chart.places[place].x * across, chart.places[place].y * down);

  /// The place under a point, or -1. A finger is allowed to be a place's
  /// width out, because a phone is not a mouse.
  int whereIs(Offset touch) {
    var nearest = -1;
    var best = spot * 1.8;
    for (var place = 0; place < chart.count; place++) {
      final away = (middleOf(place) - touch).distance;
      if (away < best) {
        best = away;
        nearest = place;
      }
    }
    return nearest;
  }
}

/// The map: the paths, the places, and the two of them on it.
class WarrenView extends CustomPainter {
  const WarrenView({
    required this.play,
    required this.canGo,
    required this.pointing,
    required this.labels,
  });

  final Play play;

  /// Places the seeker could move to.
  final List<int> canGo;

  /// A place the game is pointing at, or -1.
  final int pointing;

  /// The style the names are set in. A painter has no theme to ask.
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = play.chart;
    final metrics = Metrics(chart, size);
    final spot = metrics.spot;

    final rut = Paint()
      ..color = Palette.path
      ..strokeWidth = spot * 0.28
      ..strokeCap = StrokeCap.round;
    for (final (one, other) in chart.paths) {
      canvas.drawLine(metrics.middleOf(one), metrics.middleOf(other), rut);
    }

    for (var place = 0; place < chart.count; place++) {
      final middle = metrics.middleOf(place);
      final open = canGo.contains(place) && place != play.seeker;

      canvas.drawCircle(middle, spot, Paint()..color = Palette.place);
      canvas.drawCircle(
        middle,
        spot,
        Paint()
          ..color = open ? Palette.edge : Palette.placeEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = spot * (open ? 0.16 : 0.09),
      );
      if (place == pointing) {
        canvas.drawCircle(
          middle,
          spot * 1.42,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = spot * 0.11,
        );
      }

      final name = TextPainter(
        text: TextSpan(text: chart.places[place].name, style: labels),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: metrics.across * 0.4);
      name.paint(
        canvas,
        middle + Offset(-name.width / 2, spot * 1.1),
      );
    }

    _paintOne(canvas, metrics.middleOf(play.runner), spot, false);
    _paintOne(canvas, metrics.middleOf(play.seeker), spot, true);
  }

  void _paintOne(Canvas canvas, Offset middle, double spot, bool isSeeker) {
    final body = isSeeker ? Palette.seeker : Palette.runner;
    final rim = isSeeker ? Palette.seekerEdge : Palette.runnerEdge;

    canvas.drawCircle(
      middle,
      spot * 0.72,
      Paint()..color = body.withValues(alpha: 0.22),
    );
    canvas.drawCircle(middle, spot * 0.55, Paint()..color = body);
    canvas.drawCircle(
      middle,
      spot * 0.55,
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = spot * 0.09,
    );
  }

  @override
  bool shouldRepaint(WarrenView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.canGo.length != canGo.length ||
      !old.canGo.every(canGo.contains);
}
