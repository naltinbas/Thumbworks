import 'dart:math';

import 'package:flutter/material.dart';

import '../ways/play.dart';
import '../ways/rules.dart';
import 'palette.dart';

/// Where a village sits in a board of a given size: the places are laid
/// out on the grid the village gives, and the whole is scaled to fit.
class Metrics {
  Metrics(this.village, this.size, {this.bare = false}) {
    final across = village.places
        .map((p) => p.$1)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final down = village.places
        .map((p) => p.$2)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final pad = bare ? 34.0 : 30.0;
    step = min(
      (size.width - 2 * pad) / max(across, 1),
      (size.height - 2 * pad) / max(down, 1),
    );
    left = (size.width - across * step) / 2;
    top = (size.height - down * step) / 2;
    stone = min(step * 0.34, bare ? 40.0 : 22.0);
  }

  final Village village;
  final Size size;
  final bool bare;
  late final double step;
  late final double left;
  late final double top;

  /// How big a place is drawn.
  late final double stone;

  Offset at(int place) {
    final (x, y) = village.places[place];
    return Offset(left + x * step, top + y * step);
  }

  /// The middle of a street, where its arrow sits and where a tap for
  /// it lands.
  Offset middle(int street) {
    final (a, b) = village.streets[street];
    return (at(a) + at(b)) / 2;
  }

  /// Which street lies under [where], or null when none is near enough.
  int? under(Offset where) {
    var nearest = -1;
    var best = double.infinity;
    for (var s = 0; s < village.streetCount; s++) {
      final far = (middle(s) - where).distance;
      if (far < best) {
        best = far;
        nearest = s;
      }
    }
    return best <= max(stone * 1.6, 24.0) ? nearest : null;
  }

  /// Whether there is room for the places' letters.
  bool get roomy => stone >= 9;
}

/// The village: its places, its streets and the arrow on each.
class WayView extends CustomPainter {
  const WayView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The street the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the village alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final village = play.village;
    final m = Metrics(village, size, bare: bare);
    final round = play.roundabout;

    for (var s = 0; s < village.streetCount; s++) {
      final (from, to) = Rules.pointed(village, play.arrows, s);
      final a = m.at(from), b = m.at(to);
      final lit = s == pointing;
      final colour = lit
          ? Palette.shown
          : round
              ? Palette.gold
              : Palette.copper;
      final thick = max(1.6, m.stone * (lit ? 0.24 : 0.16));
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = colour
          ..strokeWidth = thick
          ..strokeCap = StrokeCap.round,
      );
      _arrow(canvas, a, b, m.stone, colour);
    }

    for (var p = 0; p < village.placeCount; p++) {
      final at = m.at(p);
      final lost = !round && play.stranded(p);
      canvas.drawCircle(
        at,
        m.stone,
        Paint()..color = lost ? Palette.stranded : Palette.place,
      );
      canvas.drawCircle(
        at,
        m.stone,
        Paint()
          ..color = round ? Palette.gold : Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.2, m.stone * 0.12),
      );
      if (m.roomy) {
        _word(canvas, Rules.tellPlace(p), at, m.stone * 1.05, Palette.night);
      }
    }
  }

  /// The arrowhead, sat two thirds of the way along the street.
  void _arrow(Canvas canvas, Offset a, Offset b, double stone, Color colour) {
    final along = b - a;
    final far = along.distance;
    if (far == 0) return;
    final unit = along / far;
    final head = a + unit * (far * 0.62);
    final back = stone * 0.62;
    final side = Offset(-unit.dy, unit.dx) * (back * 0.55);
    final path = Path()
      ..moveTo(head.dx, head.dy)
      ..lineTo(head.dx - unit.dx * back + side.dx, head.dy - unit.dy * back + side.dy)
      ..lineTo(head.dx - unit.dx * back - side.dx, head.dy - unit.dy * back - side.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = colour);
  }

  void _word(Canvas canvas, String words, Offset at, double size, Color colour) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(
            color: colour, fontSize: size, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(WayView old) =>
      old.play != play || old.pointing != pointing;
}
