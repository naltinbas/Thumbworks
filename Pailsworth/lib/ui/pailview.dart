import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pail/play.dart';
import 'palette.dart';

/// Where the spring, the pails and the drain stand, shared by the
/// painter and the hit-testing, so what is drawn is exactly what is
/// tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final pails = play.rules.pails;
    endWide = width * 0.16;
    laneWide = (width - endWide * 2) / pails;
    floorY = height * 0.78;
    final most = play.errand.caps.reduce(math.max);
    unit = math.min((height * 0.52) / most, 44.0);
  }

  final Play play;

  late final double width;
  late final double height;
  late final double endWide;
  late final double laneWide;
  late final double floorY;

  /// One pint's worth of height.
  late final double unit;

  Rect pailRect(int pail) {
    final cap = play.errand.caps[pail];
    final wide = laneWide * 0.62;
    final x = endWide + laneWide * pail + (laneWide - wide) / 2;
    return Rect.fromLTWH(
        x, floorY - cap * unit, wide, cap * unit);
  }

  Rect springRect() => Rect.fromLTWH(
      endWide * 0.12, floorY - unit * 3.4, endWide * 0.72, unit * 3.4);

  Rect drainRect() => Rect.fromLTWH(width - endWide * 0.84,
      floorY - unit * 1.2, endWide * 0.72, unit * 1.2);

  /// The end under a touch: a pail, the spring, the drain, or null.
  int? endAt(Offset touch) {
    for (var pail = 0; pail < play.rules.pails; pail++) {
      if (pailRect(pail).inflate(8).contains(touch)) return pail;
    }
    if (springRect().inflate(10).contains(touch)) return Play.spring;
    if (drainRect().inflate(10).contains(touch)) return Play.drain;
    return null;
  }
}

/// The well-house, drawn.
class PailView extends CustomPainter {
  PailView({
    required this.play,
    required this.armed,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The end armed as a pour's source: a pail, the spring, or null as
  /// nothing.
  final int? armed;

  /// The pour being pointed at, or null.
  final (int, int)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The floor.
    canvas.drawLine(
      Offset(metrics.width * 0.02, metrics.floorY),
      Offset(metrics.width * 0.98, metrics.floorY),
      Paint()
        ..color = Palette.line
        ..strokeWidth = 2,
    );

    _spring(canvas, metrics);
    _drain(canvas, metrics);
    for (var pail = 0; pail < play.rules.pails; pail++) {
      _pail(canvas, metrics, pail);
    }

    final pointed = pointing;
    if (pointed != null) _point(canvas, metrics, pointed);
  }

  Offset _endMiddle(Metrics metrics, int end) => end == Play.spring
      ? metrics.springRect().center
      : end == Play.drain
          ? metrics.drainRect().center
          : metrics.pailRect(end).topCenter;

  void _spring(Canvas canvas, Metrics metrics) {
    final rect = metrics.springRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.2)),
      Paint()..color = Palette.springStone,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.2)),
      Paint()
        ..color = armed == Play.spring ? Palette.armed : Palette.edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = armed == Play.spring ? 2.8 : 1.4,
    );
    // The water in the mouth.
    canvas.drawRect(
      Rect.fromLTWH(rect.left + rect.width * 0.2,
          rect.top + rect.height * 0.24, rect.width * 0.6,
          rect.height * 0.2),
      Paint()..color = Palette.water,
    );
    if (!showWords) return;
    _word(canvas, metrics, 'spring', rect.center.dx,
        rect.bottom + metrics.unit * 0.28);
  }

  void _drain(Canvas canvas, Metrics metrics) {
    final rect = metrics.drainRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.16)),
      Paint()..color = Palette.drainStone,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.16)),
      Paint()
        ..color = armed != null && armed != Play.spring
            ? Palette.edge
            : Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // The grate.
    for (var slat = 1; slat <= 3; slat++) {
      final x = rect.left + rect.width * slat / 4;
      canvas.drawLine(
        Offset(x, rect.top + rect.height * 0.25),
        Offset(x, rect.bottom - rect.height * 0.25),
        Paint()
          ..color = Palette.line
          ..strokeWidth = 2,
      );
    }
    if (!showWords) return;
    _word(canvas, metrics, 'drain', rect.center.dx,
        rect.bottom + metrics.unit * 0.28);
  }

  void _pail(Canvas canvas, Metrics metrics, int pail) {
    final rect = metrics.pailRect(pail);
    final cap = play.errand.caps[pail];
    final held = play.held[pail];

    // The water first, then the vessel's walls over it.
    if (held > 0) {
      final water = Rect.fromLTWH(
        rect.left,
        rect.bottom - held * metrics.unit,
        rect.width,
        held * metrics.unit,
      );
      canvas.drawRect(water, Paint()..color = Palette.water);
      canvas.drawRect(
        Rect.fromLTWH(water.left, water.top, water.width,
            math.min(metrics.unit * 0.16, 4)),
        Paint()..color = Palette.waterTop,
      );
    }

    final walls = Paint()
      ..color = armed == pail ? Palette.armed : Palette.pailRim
      ..style = PaintingStyle.stroke
      ..strokeWidth = armed == pail ? 3.0 : 2.2;
    canvas.drawLine(rect.topLeft, rect.bottomLeft, walls);
    canvas.drawLine(rect.topRight, rect.bottomRight, walls);
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, walls);

    // Pint lines up the side, and the ask marked where it would stand.
    for (var pint = 1; pint < cap; pint++) {
      final y = rect.bottom - pint * metrics.unit;
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.left + rect.width * 0.12, y),
        Paint()
          ..color = Palette.line
          ..strokeWidth = 1.2,
      );
    }
    if (play.errand.ask <= cap) {
      final y = rect.bottom - play.errand.ask * metrics.unit;
      final dash = rect.width * 0.12;
      var x = rect.left;
      final paint = Paint()
        ..color = Palette.askMark
        ..strokeWidth = 1.8;
      while (x < rect.right) {
        canvas.drawLine(Offset(x, y),
            Offset(math.min(x + dash, rect.right), y), paint);
        x += dash * 1.8;
      }
    }

    if (!showWords) return;
    _word(canvas, metrics, '$held of $cap', rect.center.dx,
        rect.bottom + metrics.unit * 0.28);
  }

  void _point(Canvas canvas, Metrics metrics, (int, int) pour) {
    final from = _endMiddle(metrics, pour.$1);
    final to = _endMiddle(metrics, pour.$2);
    final lift = Offset(0, -metrics.unit * 1.4);
    final paint = Paint()
      ..color = Palette.shown
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from + lift, to + lift, paint);
    final step = to.dx > from.dx ? 1.0 : -1.0;
    canvas.drawLine(
        to + lift,
        to +
            lift +
            Offset(-step * metrics.unit * 0.5, -metrics.unit * 0.3),
        paint);
    canvas.drawLine(
        to + lift,
        to +
            lift +
            Offset(-step * metrics.unit * 0.5, metrics.unit * 0.3),
        paint);
  }

  void _word(Canvas canvas, Metrics metrics, String text, double x,
      double y) {
    final words = TextPainter(
      text: TextSpan(
        text: text,
        style: labels.copyWith(
          color: Palette.inkDim,
          fontSize: math.min(metrics.unit * 0.5, 13.0),
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      Offset(
        (x - words.width / 2)
            .clamp(2.0, metrics.width - words.width - 2.0),
        y,
      ),
    );
  }

  @override
  bool shouldRepaint(PailView old) =>
      old.play != play ||
      old.armed != armed ||
      old.pointing != pointing;
}

/// The words the why speaks, from the errand at hand.
String whyWords(Play play) {
  final errand = play.errand;
  final note = errand.note == null ? '' : ' ${errand.note}';
  if (!errand.winnable) {
    final measure = play.rules.measure;
    return 'A pour fills to the brim, empties to nothing, or tips '
        'until one pail is dry or the other full: whatever the pails '
        'hold in multiples of $measure, they still hold in multiples '
        'of $measure after. Dry is such a start, and ${errand.ask} '
        'is no multiple.$note';
  }
  return 'The walk stood on every waterline these pails can reach, '
      'all ${play.rules.states} of them, and wrote down the pours '
      'from each. The errand runs in ${errand.fewest} and nothing '
      'shorter, and Show me reads from that walk.$note';
}
