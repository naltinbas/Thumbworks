import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hill/play.dart';
import 'palette.dart';

/// Where every spot lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final side = play.hill.side;
    step = math.min(
      room.width * 0.86 / side,
      room.height * 0.82 / (side * 0.87),
    );
    peak = Offset(room.width / 2,
        (room.height - side * step * 0.87) / 2 + step * 0.1);
  }

  final Play play;

  late final double step;
  late final Offset peak;

  /// The point of the spot at (row, place).
  Offset spotAt(int row, int place) => Offset(
        peak.dx + (place - row / 2) * step,
        peak.dy + row * step * 0.87,
      );

  /// The spot under a touch, or null.
  (int, int)? spotUnder(Offset touch) {
    for (var row = 0; row <= play.hill.side; row++) {
      for (var place = 0; place <= row; place++) {
        if ((spotAt(row, place) - touch).distance <= step * 0.3) {
          return (row, place);
        }
      }
    }
    return null;
  }
}

/// The hillside, drawn.
class HillView extends CustomPainter {
  HillView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The spot the show-me points at, or null.
  final (int, int)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The turf between spots.
    final turf = Paint()
      ..color = Palette.line
      ..strokeWidth = 1.4;
    for (final (a, b, c) in play.rules.patches3) {
      canvas.drawLine(metrics.spotAt(a.$1, a.$2),
          metrics.spotAt(b.$1, b.$2), turf);
      canvas.drawLine(metrics.spotAt(b.$1, b.$2),
          metrics.spotAt(c.$1, c.$2), turf);
      canvas.drawLine(metrics.spotAt(c.$1, c.$2),
          metrics.spotAt(a.$1, a.$2), turf);
    }

    // Every rainbow patch, washed and ringed.
    for (final (a, b, c) in play.rainbow) {
      final path = Path()
        ..moveTo(metrics.spotAt(a.$1, a.$2).dx,
            metrics.spotAt(a.$1, a.$2).dy)
        ..lineTo(metrics.spotAt(b.$1, b.$2).dx,
            metrics.spotAt(b.$1, b.$2).dy)
        ..lineTo(metrics.spotAt(c.$1, c.$2).dx,
            metrics.spotAt(c.$1, c.$2).dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = Palette.patch.withValues(alpha: 0.16),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.patch
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    // The spots, rim ones worn dim.
    for (var row = 0; row <= play.hill.side; row++) {
      for (var place = 0; place <= row; place++) {
        final spot = (row, place);
        final middle = metrics.spotAt(row, place);
        final plant = play.planted[spot]!;
        final fixed = !play.canPlant(spot);
        canvas.drawCircle(
          middle,
          metrics.step * 0.19,
          Paint()
            ..color = fixed
                ? Palette.plants[plant]!.withValues(alpha: 0.55)
                : Palette.plants[plant]!,
        );
        canvas.drawCircle(
          middle,
          metrics.step * 0.19,
          Paint()
            ..color = pointing == spot
                ? Palette.shown
                : fixed
                    ? Palette.line
                    : Palette.ink.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = pointing == spot ? 3.0 : 1.3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(HillView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the hill at hand.
String whyWords(Play play) {
  final hill = play.hill;
  final rules = play.rules;
  final plantings = math.pow(3, rules.inner.length).round();
  final note = hill.note == null ? '' : ' ${hill.note}';
  if (!hill.winnable) {
    return 'Sperner\'s lemma holds this hill: walk the rim and '
        'count the edges where bracken meets gorse, '
        '${rules.rimEdges()} on the whole round, and the patch '
        'count always shares that walk\'s parity. Odd, every '
        'time. The sweep planted the inside all $plantings ways '
        'and read the census on each: no even count, ever.$note';
  }
  return 'The patch census is checked against two other voices '
      'that share nothing with it: the rim walk, whose single '
      'bracken-gorse edge forces every count odd, and the sweep, '
      'which plants the inside all $plantings ways and lands '
      'exactly ${hill.ways} of them on this hill\'s asking.$note';
}
