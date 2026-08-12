import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../slice/play.dart';
import '../slice/rules.dart';
import 'palette.dart';

/// Where every spot lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height / 2);
    scale = math.min(room.width, room.height) * 0.44 / 4.0;
  }

  final Play play;

  late final Offset middle;
  late final double scale;

  /// The middle of a rim spot.
  Offset spotAt(int spot) {
    final (x, y) = Rules.spots[spot];
    return middle + Offset(x * scale, -y * scale);
  }

  /// The spot under a touch, or -1 for the table.
  int spotUnder(Offset touch) {
    for (var spot = 0; spot < Rules.spots.length; spot++) {
      if ((spotAt(spot) - touch).distance <= scale * 0.62) {
        return spot;
      }
    }
    return -1;
  }
}

/// The cake, drawn: rim, candles, every knife line, and the
/// crossings dotted, clumps in gold.
class SliceView extends CustomPainter {
  SliceView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The spot the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final scale = metrics.scale;

    // The cake, its rim through the outer spots.
    canvas.drawCircle(
        metrics.middle, scale * 4.35, Paint()..color = Palette.cake);
    canvas.drawCircle(
      metrics.middle,
      scale * 4.35,
      Paint()
        ..color = Palette.crust
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(scale * 0.22, 3.0),
    );

    // The knife lines between every pair of candles.
    for (var a = 0; a < play.picked.length; a++) {
      for (var b = a + 1; b < play.picked.length; b++) {
        canvas.drawLine(
          metrics.spotAt(play.picked[a]),
          metrics.spotAt(play.picked[b]),
          Paint()
            ..color = Palette.knife
            ..strokeWidth = math.max(scale * 0.09, 2.0),
        );
      }
    }

    // The crossings, clumps of three lines gold and wider.
    Rules.crossings(play.picked).forEach((hit, lines) {
      final (xNum, yNum, den) = hit;
      final at = metrics.middle +
          Offset(xNum / den * scale, -yNum / den * scale);
      canvas.drawCircle(
        at,
        lines > 2 ? scale * 0.3 : scale * 0.16,
        Paint()
          ..color = lines > 2 ? Palette.clump : Palette.crossing,
      );
    });

    // The rim spots and the candles.
    for (var spot = 0; spot < Rules.spots.length; spot++) {
      final at = metrics.spotAt(spot);
      final lit = play.picked.contains(spot);
      if (!lit) {
        canvas.drawCircle(
          at,
          scale * 0.2,
          Paint()
            ..color = Palette.spot
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      } else {
        canvas.drawLine(
          at + Offset(0, scale * 0.1),
          at + Offset(0, -scale * 0.42),
          Paint()
            ..color = Palette.candle
            ..strokeWidth = math.max(scale * 0.14, 3.0)
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          at + Offset(0, -scale * 0.58),
          scale * 0.17,
          Paint()..color = Palette.flame,
        );
      }
      if (pointing == spot) {
        canvas.drawCircle(
          at,
          scale * 0.55,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SliceView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the cake at hand.
String whyWords(Play play) {
  final cake = play.cake;
  final note = cake.note == null ? '' : ' ${cake.note}';
  if (!cake.winnable) {
    return 'Count the slices as the knife works: one cake before '
        'any cut, then every line adds a slice, and every crossing '
        'adds a slice again, a clump of three lines through one '
        'point paying two where spread crossings pay three. Six '
        'candles hang fifteen lines, and a crossing picks four '
        'candles, fifteen picks at the most: one plus fifteen plus '
        'fifteen is thirty-one, and clumping only loses. The sweep '
        'set all 924 picks and found thirty-one or thirty, never '
        'more.$note';
  }
  return 'The slices are counted two ways that share nothing: '
      'Euler\'s reckoning over the whole arrangement, spots and '
      'crossings less the edges, and the cut count, one plus a '
      'slice per line plus a slice per crossing, clumps paying '
      'their lines less one. The sweep sets every pick of the rim '
      'and the two agree on all of them. ${cake.ways} '
      'pick${cake.ways == 1 ? '' : 's'} '
      'land${cake.ways == 1 ? 's' : ''} this cake.$note';
}
