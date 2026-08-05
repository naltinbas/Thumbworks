import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../round/play.dart';
import 'palette.dart';

/// Where everything on the parish is.
///
/// The painter and the finger both use this, which is the point of it: a lane
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    spot = math.min(room.width, room.height) * 0.04;
    width = spot * 1.5;

    // The parish is laid out to fill what it is given rather than to sit
    // inside a square nobody chose, so a wide one and a tall one are both as
    // big as they can be. The two ways round are scaled the same, so nothing
    // is drawn out of shape.
    final junctions = play.parish.junctions;
    var leftmost = 1.0, rightmost = 0.0, topmost = 1.0, lowest = 0.0;
    for (final junction in junctions) {
      leftmost = math.min(leftmost, junction.x);
      rightmost = math.max(rightmost, junction.x);
      topmost = math.min(topmost, junction.y);
      lowest = math.max(lowest, junction.y);
    }
    final wide = math.max(rightmost - leftmost, 0.01);
    final tall = math.max(lowest - topmost, 0.01);

    final margin = spot * 3;
    scale = math.min(
      (room.width - margin * 2) / wide,
      (room.height - margin * 2) / tall,
    );
    corner = Offset(
      (room.width - wide * scale) / 2 - leftmost * scale,
      (room.height - tall * scale) / 2 - topmost * scale,
    );
  }

  final Play play;

  late final double spot;

  /// How wide a lane is drawn.
  late final double width;

  /// How much of the screen one unit of the parish is worth.
  late final double scale;

  late final Offset corner;

  Offset middleOf(int junction) =>
      corner +
      Offset(play.parish.junctions[junction].x * scale,
          play.parish.junctions[junction].y * scale);

  /// The junction under a point, or -1.
  int junctionAt(Offset touch) {
    var nearest = -1;
    var best = spot * 2.4;
    for (var junction = 0; junction < play.parish.count; junction++) {
      final away = (middleOf(junction) - touch).distance;
      if (away < best) {
        best = away;
        nearest = junction;
      }
    }
    return nearest;
  }

  /// The lane under a point, or -1. A tap on the middle of a lane is a tap on
  /// that lane rather than on whichever junction happens to be nearer.
  int laneAt(Offset touch) {
    var nearest = -1;
    var best = width * 1.4;
    for (var lane = 0; lane < play.parish.laneCount; lane++) {
      final away = _awayFrom(
        touch,
        middleOf(play.parish.lanes[lane].from),
        middleOf(play.parish.lanes[lane].to),
      );
      if (away < best) {
        best = away;
        nearest = lane;
      }
    }
    return nearest;
  }

  static double _awayFrom(Offset point, Offset one, Offset other) {
    final along = other - one;
    final length = along.distanceSquared;
    if (length == 0) return (point - one).distance;
    final how = (((point - one).dx * along.dx + (point - one).dy * along.dy) /
            length)
        .clamp(0.0, 1.0);
    return (point - (one + along * how)).distance;
  }
}

/// The parish: the lanes, which of them are salted, and where the lorry is.
class ParishView extends CustomPainter {
  const ParishView({
    required this.play,
    required this.pointing,
    required this.labels,
    this.showOdd = false,
    this.showLorry = true,
  });

  final Play play;

  /// A junction the game is pointing at, or -1.
  final int pointing;

  /// The style the names are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Whether to ring the junctions with an odd number of lanes on them, which
  /// is what the game shows when it is asked why a parish takes what it does.
  final bool showOdd;

  /// Off for the mark, where the picture is the lanes.
  final bool showLorry;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final parish = play.parish;
    final salted = play.saltedSet;
    final at = play.at;
    final last = play.moves.isEmpty || play.moves.last.isSetOff
        ? -1
        : play.moves.last.lane;

    for (var lane = 0; lane < parish.laneCount; lane++) {
      final one = metrics.middleOf(parish.lanes[lane].from);
      final other = metrics.middleOf(parish.lanes[lane].to);
      final done = salted.contains(lane);

      canvas.drawLine(
        one,
        other,
        Paint()
          ..color = done ? Palette.grit : Palette.lane
          ..strokeWidth = metrics.width
          ..strokeCap = StrokeCap.round,
      );
      if (done) {
        canvas.drawLine(
          one,
          other,
          Paint()
            ..color = lane == last ? Palette.ink : Palette.salted
            ..strokeWidth = metrics.width * 0.42
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    for (var junction = 0; junction < parish.count; junction++) {
      final middle = metrics.middleOf(junction);
      final odd = parish.lanesOn(junction).isOdd;

      canvas.drawCircle(
        middle,
        metrics.spot,
        Paint()..color = Palette.verge,
      );
      final ringed = showOdd && odd;
      canvas.drawCircle(
        middle,
        metrics.spot,
        Paint()
          ..color = ringed ? Palette.salted : Palette.edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = metrics.spot * (ringed ? 0.38 : 0.2),
      );

      if (junction == pointing) {
        canvas.drawCircle(
          middle,
          metrics.spot * 2,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.spot * 0.16,
        );
      }

      final name = TextPainter(
        text: TextSpan(
          text: parish.junctions[junction].name,
          style: labels.copyWith(color: Palette.inkDim),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final where = middle + Offset(-name.width / 2, metrics.spot * 1.4);

      // A name that lands on a lane is unreadable without something behind
      // it, and lanes go everywhere.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(where.dx, where.dy, name.width, name.height)
              .inflate(metrics.spot * 0.18),
          Radius.circular(metrics.spot * 0.3),
        ),
        Paint()..color = Palette.night.withValues(alpha: 0.82),
      );
      name.paint(canvas, where);
    }

    if (showLorry && at >= 0) _lorry(canvas, metrics.middleOf(at), metrics.spot);
  }

  /// The lorry, standing at a junction with its lamps on.
  void _lorry(Canvas canvas, Offset middle, double spot) {
    canvas.drawCircle(
      middle,
      spot * 1.9,
      Paint()..color = Palette.lorry.withValues(alpha: 0.14),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: middle,
          width: spot * 1.7,
          height: spot * 1.15,
        ),
        Radius.circular(spot * 0.3),
      ),
      Paint()..color = Palette.lorry,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: middle + Offset(spot * 0.42, 0),
          width: spot * 0.5,
          height: spot * 0.72,
        ),
        Radius.circular(spot * 0.14),
      ),
      Paint()..color = Palette.night,
    );
  }

  @override
  bool shouldRepaint(ParishView old) =>
      old.play != play || old.pointing != pointing || old.showOdd != showOdd;
}
