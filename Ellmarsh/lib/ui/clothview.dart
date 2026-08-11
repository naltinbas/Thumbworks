import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cloth/play.dart';
import 'palette.dart';

/// Where the bolts lie, shared by the painter and the hit-testing, so
/// where a bolt is drawn is exactly where a bolt is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    // The long bolt fills most of the width; everything scales off the
    // ell so both bolts share a ruler.
    final longest = math.max(play.long, play.bench.long);
    ell = (width - 32) / longest;
    bolt = math.min(height * 0.16, 54.0);
    longTop = height * 0.24;
    shortTop = longTop + bolt * 2.0;
  }

  final Play play;

  late final double width;
  late final double height;

  /// Pixels to the ell, and a bolt's height.
  late final double ell;
  late final double bolt;
  late final double longTop;
  late final double shortTop;

  Rect longRect() => Rect.fromLTWH(16, longTop, play.long * ell, bolt);
  Rect shortRect() => Rect.fromLTWH(16, shortTop, play.short * ell, bolt);

  /// Where the golden ratio times the short bolt falls on the ruler.
  double goldenX() => 16 + play.short * ell * (1 + math.sqrt(5)) / 2;

  /// Whether a touch lands on the long bolt.
  bool onLong(Offset touch) => longRect().inflate(10).contains(touch);
}

/// The bench, drawn.
class ClothView extends CustomPainter {
  ClothView({
    required this.play,
    required this.pending,
    required this.showGap,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// Cuts marked, in times of the short bolt, shaded from the long
  /// bolt's end.
  final int pending;

  /// Whether to draw the golden tick.
  final bool showGap;

  /// Whether counts may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    if (play.isOver) {
      _bolt(canvas, metrics, metrics.shortRect(), play.short,
          Palette.shortCloth, Palette.shortSelvedge, 'the bolt that stays');
      return;
    }

    _bolt(canvas, metrics, metrics.longRect(), play.long,
        Palette.longCloth, Palette.longSelvedge, 'the long bolt');
    _bolt(canvas, metrics, metrics.shortRect(), play.short,
        Palette.shortCloth, Palette.shortSelvedge, 'the short bolt');
    _ticks(canvas, metrics);
    if (pending > 0) _pending(canvas, metrics);
    if (showGap) _golden(canvas, metrics);
  }

  void _bolt(Canvas canvas, Metrics metrics, Rect rect, int ells,
      Color cloth, Color selvedge, String said) {
    final round = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height * 0.22),
    );
    canvas.drawRRect(round, Paint()..color = cloth);
    // Selvedge stripes along both edges.
    final stripe = Paint()
      ..color = selvedge
      ..strokeWidth = math.max(1.6, rect.height * 0.09);
    canvas.drawLine(
      rect.topLeft + Offset(3, rect.height * 0.12),
      rect.topRight + Offset(-3, rect.height * 0.12),
      stripe,
    );
    canvas.drawLine(
      rect.bottomLeft + Offset(3, -rect.height * 0.12),
      rect.bottomRight + Offset(-3, -rect.height * 0.12),
      stripe,
    );

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '$ells',
        style: labels.copyWith(
          color: Palette.ink,
          fontSize: rect.height * 0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      Offset(rect.right + 7, rect.center.dy - words.height / 2),
    );
  }

  void _ticks(Canvas canvas, Metrics metrics) {
    // The short bolt laid off along the long one: a tick at every
    // multiple, which is where cuts can fall.
    final rect = metrics.longRect();
    final tick = Paint()
      ..color = Palette.shop.withValues(alpha: 0.55)
      ..strokeWidth = 1.6;
    for (var times = 1; times * play.short < play.long; times++) {
      final x = rect.left + times * play.short * metrics.ell;
      canvas.drawLine(
        Offset(x, rect.top + 2),
        Offset(x, rect.bottom - 2),
        tick,
      );
    }
  }

  void _pending(Canvas canvas, Metrics metrics) {
    final rect = metrics.longRect();
    final width = pending * play.short * metrics.ell;
    final shade = Rect.fromLTWH(
      rect.right - width,
      rect.top,
      width,
      rect.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shade, Radius.circular(rect.height * 0.22)),
      Paint()..color = Palette.marked.withValues(alpha: 0.30),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shade, Radius.circular(rect.height * 0.22)),
      Paint()
        ..color = Palette.marked
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  void _golden(Canvas canvas, Metrics metrics) {
    // The golden tick: phi times the short bolt, on the long bolt's
    // ruler. The long bolt reaching past it is the whole verdict.
    final x = metrics.goldenX();
    final rect = metrics.longRect();
    final gold = Paint()
      ..color = Palette.golden
      ..strokeWidth = 2.6;
    canvas.drawLine(
      Offset(x, rect.top - metrics.bolt * 0.5),
      Offset(x, rect.bottom + metrics.bolt * 0.5),
      gold,
    );
    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: 'the gap ends here',
        style: labels.copyWith(
          color: Palette.golden,
          fontSize: metrics.bolt * 0.3,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final at = Offset(
      (x - words.width / 2)
          .clamp(4.0, metrics.width - words.width - 4.0),
      rect.top - metrics.bolt * 0.5 - words.height - 3,
    );
    words.paint(canvas, at);
  }

  @override
  bool shouldRepaint(ClothView old) =>
      old.play != play ||
      old.pending != pending ||
      old.showGap != showGap;
}

/// The words the why speaks, from the bench at hand.
String whyWords(Play play) {
  final long = play.long;
  final short = play.short;
  final square = long * long;
  final gapEnd = long * short + short * short;
  final start = 'The cutter holds the bench exactly when the long bolt '
      'reaches the golden ratio times the short, and the whole numbers '
      'can say it without measuring: $long times $long is $square, '
      'against $long times $short plus $short times $short, $gapEnd.';
  final verdict = square >= gapEnd
      ? ' $square reaches $gapEnd: the bench is the cutter\'s, and the '
          'cut that holds it leaves the other side inside the gap.'
      : ' $square falls short of $gapEnd: inside the gap, the only cut '
          'is the forced one, and the count runs against the cutter to '
          'the end.';
  final note = play.bench.note;
  return '$start$verdict${note == null ? '' : ' $note'}';
}
