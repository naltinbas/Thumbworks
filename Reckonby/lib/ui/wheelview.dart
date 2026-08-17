import 'dart:math';

import 'package:flutter/material.dart';

import '../count/play.dart';
import '../count/rules.dart';
import 'palette.dart';

/// Where the wheels stand in a board of a given size. Each wheel is a
/// column of notches, the cheapest wheel on the right the way a number
/// is written.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    pad = bare ? size.width * 0.05 : 14.0;
    final words = bare ? 0.0 : 44.0;
    wide = (size.width - pad * 2) / Rules.wheels;
    final room = size.height - words - (bare ? 0.0 : 10.0);
    notch = min(room / (Rules.wheels + 2), wide * 0.44);
    // The board hangs the wheels from the top and leaves room under
    // them for their worths; the mark stands them in the middle.
    floor = bare
        ? (size.height + notch * (Rules.wheels + 1)) / 2
        : 10.0 + notch * (Rules.wheels + 1);
  }

  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double pad, wide, notch, floor;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 180 && size.width >= 240;

  /// Which column a wheel is drawn in: the cheapest on the right.
  int columnOf(int wheel) => Rules.wheels - wheel;

  /// One notch of a wheel, counted from the bottom.
  Rect notchAt(int wheel, int step) => Rect.fromLTWH(
        pad + columnOf(wheel) * wide + wide * 0.2,
        floor - (step + 1) * notch + 1.5,
        wide * 0.6,
        notch - 3,
      );
}

/// The wheels, the notch each stands at, and what the house reads.
class WheelView extends CustomPainter {
  const WheelView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the wheels alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);
    for (var wheel = 1; wheel <= Rules.wheels; wheel++) {
      final at = play.wheels[wheel - 1];
      final wanted = pointing?.$1 == wheel;
      for (var step = 0; step <= Rules.top(wheel); step++) {
        final on = step == at;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              m.notchAt(wheel, step), Radius.circular(m.notch * 0.24)),
          Paint()
            ..color = on
                ? (wanted ? Palette.shown : Palette.lit)
                : Palette.drum.withValues(alpha: step < at ? 0.75 : 0.35),
        );
        if (!bare && m.notch > 12) {
          _word(canvas, '$step', m.notchAt(wheel, step).center,
              on ? Palette.night : Palette.inkDim, size, m.notch * 0.42);
        }
      }
      if (bare) continue;
      // What the wheel is worth, and what it is putting in.
      final box = m.notchAt(wheel, 0);
      _word(canvas, Rules.tellWorth(wheel),
          Offset(box.center.dx, m.floor + 10), Palette.inkDim, size, 10);
      _word(canvas, 'is ${Rules.worth(wheel)}',
          Offset(box.center.dx, m.floor + 22), Palette.inkDim, size, 9);
      _word(canvas, '${at * Rules.worth(wheel)}',
          Offset(box.center.dx, m.floor + 35), Palette.brass, size, 11);
    }
    if (bare || !m.roomy) return;
    _word(
        canvas,
        'each wheel puts in what it stands at times what it is worth',
        Offset(size.width / 2, size.height - 8),
        Palette.inkDim,
        size,
        10);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(WheelView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}
