import 'dart:math';

import 'package:flutter/material.dart';

import '../road/play.dart';
import '../road/rules.dart';
import 'palette.dart';

/// Where the four junctions sit in a board of a given size: Start on
/// the left, End on the right, the top and bottom junctions between.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare ? 0.0 : (roomy ? 30.0 : 0.0);
    final w = size.width, h = size.height - strip;
    final margin = bare ? 0.12 * min(w, h) : 34.0;
    start = Offset(margin, h / 2);
    end = Offset(w - margin, h / 2);
    top = Offset(w / 2, margin);
    bottom = Offset(w / 2, h - margin);
  }

  final Play play;
  final Size size;
  late final Offset start, end, top, bottom;

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The two ways and the shortcut, each road as wide as its crowd, its
/// minutes beside it.
class RoadView extends CustomPainter {
  const RoadView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the map only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final (top, bottom, across) = play.settled;
    final startTop = top + across, bottomEnd = bottom + across;
    double width(int hundreds) => (bare ? 3.0 : 1.5) + hundreds * (bare ? 0.35 : 0.22);
    void road(Offset a, Offset b, int hundreds, Color colour, {bool dashed = false}) {
      final paint = Paint()..color = colour..strokeWidth = width(hundreds)..strokeCap = StrokeCap.round;
      if (!dashed) {
        canvas.drawLine(a, b, paint);
        return;
      }
      final total = (b - a).distance, u = (b - a) / total;
      for (var d = 0.0; d < total; d += 12) {
        canvas.drawLine(a + u * d, a + u * min(d + 6, total), paint..strokeWidth = 1.5);
      }
    }
    // The four roads and the shortcut.
    road(m.start, m.top, startTop, startTop > 0 ? Palette.road : Palette.roadDim);
    road(m.top, m.end, top, top > 0 ? Palette.fixedRoad : Palette.roadDim);
    road(m.start, m.bottom, bottom, bottom > 0 ? Palette.fixedRoad : Palette.roadDim);
    road(m.bottom, m.end, bottomEnd, bottomEnd > 0 ? Palette.road : Palette.roadDim);
    if (play.open) {
      road(m.top, m.bottom, across, across > 0 ? Palette.shortcut : Palette.roadDim);
    } else {
      road(m.top, m.bottom, 0, Palette.shortcutShut, dashed: true);
    }
    // The junctions.
    for (final (at, name) in [(m.start, 'Start'), (m.end, 'End'), (m.top, 'top'), (m.bottom, 'bottom')]) {
      canvas.drawCircle(at, bare ? 10 : 7, Paint()..color = Palette.junction);
      if (!bare) {
        final dy = at == m.top ? -16.0 : at == m.bottom ? 16.0 : 0.0;
        final dx = at == m.start ? -2.0 : at == m.end ? 2.0 : 0.0;
        _word(canvas, name, at + Offset(dx, dy == 0 ? 16 : dy), Palette.inkDim, size, 11);
      }
    }
    if (bare) return;
    // The minutes on each road.
    // Each road's words sit off it, on the outer side, backed on night
    // so they read over the roads.
    final middle = Offset.lerp(m.start, m.end, 0.5)!;
    Offset out(Offset a, Offset b, double sign) {
      final d = b - a;
      var n = Offset(-d.dy, d.dx) / d.distance;
      final mid = Offset.lerp(a, b, 0.5)!;
      // Outward: the side away from the middle of the map.
      if ((mid + n - middle).distance < (mid - n - middle).distance) n = -n;
      return mid + n * (size.height < 300 ? 16 : 26);
    }
    // On a short board the words shrink to the minutes alone.
    final compact = size.height < 300;
    _word(canvas, compact ? '$startTop min' : '$startTop min, $startTop hundred', out(m.start, m.top, 1), Palette.road, size, 11, backed: true);
    _word(canvas, compact ? '${Rules.fixed}' : '${Rules.fixed} min', out(m.top, m.end, 1), Palette.inkDim, size, 11, backed: true);
    _word(canvas, compact ? '${Rules.fixed}' : '${Rules.fixed} min', out(m.start, m.bottom, -1), Palette.inkDim, size, 11, backed: true);
    _word(canvas, compact ? '$bottomEnd min' : '$bottomEnd min, $bottomEnd hundred', out(m.bottom, m.end, -1), Palette.road, size, 11, backed: true);
    _word(canvas, play.open ? (compact ? '$across across' : '0 min, $across hundred') : 'shut', Offset.lerp(m.top, m.bottom, 0.5)!, play.open ? Palette.shortcut : Palette.inkDim, size, 11, backed: true);
    if (!m.roomy) return;
    final other = play.open ? play.journeyShut : play.journeyOpen;
    final gap = play.journey - other;
    _word(
      canvas,
      'everyone takes ${play.journey} minutes, ${gap == 0 ? 'the same' : gap > 0 ? '$gap more than' : '${-gap} fewer than'} with the shortcut ${play.open ? 'shut' : 'open'}',
      Offset(size.width / 2, size.height - 12),
      gap == 0 ? Palette.inkDim : (play.open == (gap < 0)) ? Palette.faster : Palette.slower,
      size,
      12,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool backed = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize))),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    if (backed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 3, y - 1, text.width + 6, text.height + 2), const Radius.circular(4)),
        Paint()..color = Palette.night,
      );
    }
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(RoadView old) => old.play != play || old.bare != bare;
}
