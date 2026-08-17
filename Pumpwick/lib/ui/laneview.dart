import 'dart:math';

import 'package:flutter/material.dart';

import '../lane/play.dart';
import '../lane/rules.dart';
import 'palette.dart';

/// Where the lane lies in a board of a given size: across the middle,
/// the houses standing on it and the pump below.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    final pad = min(bare ? 12.0 : 18.0, size.width * 0.06);
    step = max(2.0, (size.width - 2 * pad) / Rules.spots);
    left = (size.width - step * Rules.spots) / 2 + step / 2;
    middle = size.height * (bare ? 0.5 : 0.44);
    house = max(2.0, min(step * 0.62, bare ? 46.0 : 30.0));
  }

  final Size size;
  final bool bare;

  /// How far apart the spots on the lane stand.
  late final double step;
  late final double left;
  late final double middle;

  /// How big a house is drawn.
  late final double house;

  double xOf(int spot) => left + spot * step;

  /// Which spot lies under [where], or null when none does.
  int? under(Offset where) {
    final spot = ((where.dx - left + step / 2) / step).floor();
    return Rules.onLane(spot) ? spot : null;
  }

  bool get roomy => step >= 18;
}

/// The lane, the houses on it, the pump and the walks to it.
class LaneView extends CustomPainter {
  const LaneView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// Which way the show-me points, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the lane alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);

    // The lane.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          m.xOf(0) - m.step * 0.6,
          m.middle - m.house * 0.16,
          m.xOf(Rules.spots - 1) + m.step * 0.6,
          m.middle + m.house * 0.16,
        ),
        Radius.circular(m.house * 0.16),
      ),
      Paint()..color = Palette.lane,
    );

    // The walks from each house to the pump.
    // Below the numbers along the lane, so nothing sits on top of it.
    final pumpAt = Offset(m.xOf(play.spot), m.middle + m.house * 1.25);
    for (final house in play.houses) {
      canvas.drawLine(
        Offset(m.xOf(house), m.middle - m.house * 0.2),
        pumpAt,
        Paint()
          ..color = Palette.gold.withValues(alpha: 0.45)
          ..strokeWidth = max(1.0, m.house * 0.05),
      );
    }

    // The houses, stacked where more than one shares a spot.
    final atSpot = <int, int>{};
    for (final house in play.houses) {
      atSpot[house] = (atSpot[house] ?? 0) + 1;
    }
    atSpot.forEach((spot, many) {
      for (var k = 0; k < many; k++) {
        final at = Offset(
          m.xOf(spot),
          m.middle - m.house * (0.55 + k * 0.62),
        );
        final body = Rect.fromCenter(
          center: at,
          width: m.house * 0.72,
          height: m.house * 0.56,
        );
        canvas.drawRect(body, Paint()..color = Palette.house);
        canvas.drawPath(
          Path()
            ..moveTo(body.left - m.house * 0.08, body.top)
            ..lineTo(body.center.dx, body.top - m.house * 0.28)
            ..lineTo(body.right + m.house * 0.08, body.top)
            ..close(),
          Paint()..color = Palette.roof,
        );
      }
    });

    // The pump.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: pumpAt,
          width: m.house * 0.4,
          height: m.house * 0.8,
        ),
        Radius.circular(m.house * 0.1),
      ),
      Paint()..color = Palette.pump,
    );
    canvas.drawLine(
      pumpAt.translate(0, -m.house * 0.2),
      pumpAt.translate(m.house * 0.42, -m.house * 0.3),
      Paint()
        ..color = Palette.pump
        ..strokeWidth = max(1.6, m.house * 0.12)
        ..strokeCap = StrokeCap.round,
    );
    if (pointing != null) {
      final to = Offset(m.xOf(play.spot + pointing!), pumpAt.dy);
      canvas.drawCircle(
        to,
        m.house * 0.45,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.6, m.house * 0.1),
      );
    }

    if (bare || !m.roomy) return;
    for (var spot = 0; spot < Rules.spots; spot++) {
      _word(
        canvas,
        '$spot',
        Offset(m.xOf(spot), m.middle + m.house * 0.42),
        10,
        spot == play.spot ? Palette.pump : Palette.inkDim,
      );
    }
    _word(
      canvas,
      'the walking comes to ${play.walk}',
      Offset(size.width / 2, pumpAt.dy + m.house * 1.1),
      14,
      play.walk == play.least ? Palette.gold : Palette.ink,
    );
    _word(
      canvas,
      play.walk == play.least
          ? 'which is the least there is'
          : 'the least there is is ${play.least}',
      Offset(size.width / 2, pumpAt.dy + m.house * 1.1 + 18),
      11,
      Palette.inkDim,
    );
  }

  void _word(
    Canvas canvas,
    String words,
    Offset at,
    double size,
    Color colour,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(color: colour, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(LaneView old) =>
      old.play != play || old.pointing != pointing;
}
