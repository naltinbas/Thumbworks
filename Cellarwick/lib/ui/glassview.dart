import 'dart:math';

import 'package:flutter/material.dart';

import '../glass/play.dart';
import 'palette.dart';

/// Where the two glasses sit in a board of a given size: units to
/// pixels, ten units the full height.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 44.0 : 0.0;
    glassWidth = min(90.0, size.width * 0.26);
    glassHeight = min(size.height - strip - 40, 260.0);
    unit = glassHeight / 10;
    floor = (size.height - strip) / 2 + glassHeight / 2;
    left = Rect.fromLTWH(size.width * 0.5 - glassWidth - 40, floor - glassHeight, glassWidth, glassHeight);
    right = Rect.fromLTWH(size.width * 0.5 + 40, floor - glassHeight, glassWidth, glassHeight);
  }

  final Play play;
  final Size size;
  late final double glassWidth, glassHeight, unit, floor;
  late final Rect left, right;

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The two glasses after the pouring, and the spoon between.
class GlassView extends CustomPainter {
  const GlassView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the glasses only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final pouring = play.pouring;
    // The wine glass: wine to its volume, a band of water at the foot
    // as much as came back; the water glass likewise with wine.
    final waterInWine = pouring == null ? 0.0 : pouring.$1.toDouble;
    final wineInWater = pouring == null ? 0.0 : pouring.$2.toDouble;
    _glass(canvas, m, m.left, play.wine.toDouble(), Palette.wine, waterInWine, Palette.water);
    _glass(canvas, m, m.right, play.water.toDouble(), Palette.water, wineInWater, Palette.wine);
    // The spoon between, its bowl sized to the spoonful.
    final mid = Offset(size.width / 2, m.floor - m.glassHeight * 0.55);
    final bowl = 6 + play.spoon * 3.0;
    canvas.drawLine(mid + Offset(0, bowl), mid + Offset(0, bowl + 30), Paint()..color = Palette.spoon..strokeWidth = bare ? 5 : 3);
    canvas.drawOval(Rect.fromCenter(center: mid, width: bowl * 1.6, height: bowl * 1.1), Paint()..color = pouring == null ? Palette.misfit : Palette.spoon);
    if (bare || !m.roomy) return;
    _word(canvas, 'wine, ${play.wine}', Offset(m.left.center.dx, m.left.top - 12), Palette.wineLight, size);
    _word(canvas, 'water, ${play.water}', Offset(m.right.center.dx, m.right.top - 12), Palette.waterLight, size);
    _word(canvas, 'spoon ${play.spoon}', mid + Offset(0, bowl + 42), Palette.spoon, size);
    if (pouring == null) {
      _word(canvas, 'the spoon holds more than the wine glass: nothing to carry', Offset(size.width / 2, size.height - 11), Palette.misfit, size);
      return;
    }
    _word(canvas, 'water in the wine: ${pouring.$1} of a unit', Offset(m.left.center.dx, m.floor + 14), Palette.waterLight, size);
    _word(canvas, 'wine in the water: ${pouring.$2}', Offset(m.right.center.dx, m.floor + 14), Palette.wineLight, size);
    _word(canvas, pouring.$1 == pouring.$2 ? 'the same, as they always are' : 'unequal', Offset(size.width / 2, size.height - 11), Palette.inkDim, size);
  }

  void _glass(Canvas canvas, Metrics m, Rect r, double volume, Color colour, double band, Color bandColour) {
    final fillTop = r.bottom - volume * m.unit;
    canvas.drawRect(Rect.fromLTRB(r.left, fillTop, r.right, r.bottom), Paint()..color = colour);
    if (band > 0) {
      final bandTop = r.bottom - band * m.unit;
      canvas.drawRect(Rect.fromLTRB(r.left, bandTop, r.right, r.bottom), Paint()..color = bandColour.withValues(alpha: 0.85));
    }
    // The glass itself: sides and foot.
    final outline = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.left, r.bottom)
      ..lineTo(r.right, r.bottom)
      ..lineTo(r.right, r.top);
    canvas.drawPath(
      outline,
      Paint()
        ..color = Palette.glass
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 5 : 2.5,
    );
    // Unit lines up the side.
    for (var u = 1; u < 10; u++) {
      final y = r.bottom - u * m.unit;
      canvas.drawLine(Offset(r.left, y), Offset(r.left + 6, y), Paint()..color = Palette.glass..strokeWidth = 1);
    }
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(GlassView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
