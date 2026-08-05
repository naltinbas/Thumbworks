import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../watch/play.dart';
import 'palette.dart';

/// Where everything on the country is.
///
/// The painter and the finger both use this, which is the point of it: a hill
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    final side = math.min(room.width, room.height);
    spot = side * 0.045;
    final area = side - spot * 4;
    across = area;
    down = area;
    corner = Offset((room.width - area) / 2, (room.height - area) / 2);
  }

  final Play play;

  late final double spot;
  late final double across;
  late final double down;
  late final Offset corner;

  Offset middleOf(int hill) =>
      corner +
      Offset(play.watchland.hills[hill].x * across,
          play.watchland.hills[hill].y * down);

  /// The hill under a point, or -1.
  int hillAt(Offset touch) {
    var nearest = -1;
    var best = spot * 2.2;
    for (var hill = 0; hill < play.count; hill++) {
      final away = (middleOf(hill) - touch).distance;
      if (away < best) {
        best = away;
        nearest = hill;
      }
    }
    return nearest;
  }
}

/// The country: the hills, what they can see, and which of them are lit.
class WatchView extends CustomPainter {
  const WatchView({
    required this.play,
    required this.pointing,
    required this.labels,
  });

  final Play play;

  /// A hill the game is pointing at, or -1.
  final int pointing;

  /// The style the names are set in. A painter has no theme to ask.
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final spot = metrics.spot;

    for (final (one, other) in play.watchland.sightlines) {
      final carrying = play.hasBeacon(one) || play.hasBeacon(other);
      canvas.drawLine(
        metrics.middleOf(one),
        metrics.middleOf(other),
        Paint()
          ..color = carrying ? Palette.reach : Palette.line
          ..strokeWidth = carrying ? spot * 0.18 : spot * 0.1,
      );
    }

    for (var hill = 0; hill < play.count; hill++) {
      final middle = metrics.middleOf(hill);
      final lit = play.isLit(hill);
      final beacon = play.hasBeacon(hill);

      if (beacon) {
        canvas.drawCircle(
          middle,
          spot * 1.7,
          Paint()..color = Palette.lit.withValues(alpha: 0.16),
        );
      }
      canvas.drawCircle(
        middle,
        spot,
        Paint()..color = lit ? Palette.lit : Palette.moor,
      );
      canvas.drawCircle(
        middle,
        spot,
        Paint()
          ..color = beacon
              ? Palette.beacon
              : lit
                  ? Palette.lit
                  : Palette.dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = spot * (beacon ? 0.3 : 0.16),
      );
      if (beacon) {
        canvas.drawCircle(middle, spot * 0.4, Paint()..color = Palette.beacon);
      }
      if (hill == pointing) {
        canvas.drawCircle(
          middle,
          spot * 2.1,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = spot * 0.14,
        );
      }

      final name = TextPainter(
        text: TextSpan(
          text: play.watchland.hills[hill].name,
          style: labels.copyWith(
            color: lit ? Palette.inkDim : Palette.dark,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      name.paint(canvas, middle + Offset(-name.width / 2, spot * 1.35));
    }
  }

  @override
  bool shouldRepaint(WatchView old) =>
      old.play != play || old.pointing != pointing;
}
