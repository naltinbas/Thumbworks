import 'dart:math';

import 'package:flutter/material.dart';

import '../alms/play.dart';
import '../alms/rules.dart';
import 'palette.dart';

/// Where the bins stand in a board of a given size, and where a tap on
/// one lands.
class Metrics {
  Metrics(this.size, {this.bare = false, this.tallest = Rules.grain}) {
    pad = bare ? size.width * 0.06 : 14.0;
    final words = bare ? 0.0 : 26.0;
    wide = (size.width - pad * 2) / Rules.bins;
    floor = size.height - words - (bare ? 0.0 : 14.0);
    final room = floor - (bare ? size.height * 0.08 : 34.0);
    measure = min(room / tallest, wide * 0.5);
  }

  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  /// How many measures the bins are drawn to hold. The board draws them
  /// to their full depth; the mark draws only as deep as it needs.
  final int tallest;

  late final double pad, wide, floor, measure;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 170 && size.width >= 240;

  /// The whole column a bin owns, which is what a thumb taps.
  Rect binAt(int bin) =>
      Rect.fromLTWH(pad + bin * wide, 0, wide, size.height);

  /// One measure of grain in a bin, counted from the bottom.
  Rect grainAt(int bin, int height) => Rect.fromLTWH(
        pad + bin * wide + wide * 0.18,
        floor - (height + 1) * measure + 1,
        wide * 0.64,
        measure - 2,
      );

  /// The bin a tap at [at] means, or null when it lands outside them.
  int? binNear(Offset at) {
    if (at.dx < pad || at.dx > size.width - pad) return null;
    final bin = ((at.dx - pad) / wide).floor();
    return bin < 0 || bin >= Rules.bins ? null : bin;
  }
}

/// The bins, the grain in them, and the measure in hand.
class AlmsView extends CustomPainter {
  const AlmsView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the bins alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    var deepest = 1;
    for (final at in play.bins) {
      if (at + 1 > deepest) deepest = at + 1;
    }
    final m = Metrics(size,
        bare: bare, tallest: bare ? deepest : Rules.grain);
    canvas.drawLine(Offset(m.pad, m.floor), Offset(size.width - m.pad, m.floor),
        Paint()
          ..color = Palette.line
          ..strokeWidth = bare ? 4 : 2);
    for (var bin = 0; bin < Rules.bins; bin++) {
      final lit = play.holding == bin;
      final held = play.holding;
      final wanted = pointing != null &&
          (held == null ? pointing!.$1 == bin : pointing!.$2 == bin);
      for (var height = 0; height < play.bins[bin]; height++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              m.grainAt(bin, height), Radius.circular(m.measure * 0.22)),
          Paint()..color = Palette.grain,
        );
      }
      // The bin itself, drawn as two staves and a floor.
      final box = Rect.fromLTWH(m.pad + bin * m.wide + m.wide * 0.12,
          m.floor - m.tallest * m.measure, m.wide * 0.76,
          m.tallest * m.measure);
      canvas.drawRect(
        box,
        Paint()
          ..color = wanted
              ? Palette.shown
              : (lit ? Palette.held : Palette.bin)
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : (lit || wanted ? 2.4 : 1.2),
      );
      if (bare) continue;
      _word(canvas, '${bin + 1}', Offset(box.center.dx, m.floor + 12),
          lit ? Palette.held : Palette.inkDim, size, 11);
      if (play.bins[bin] > 0) {
        _word(
            canvas,
            '${play.bins[bin]}',
            Offset(box.center.dx,
                m.floor - play.bins[bin] * m.measure - 9),
            Palette.ink,
            size,
            11);
      }
    }
    // The measure in hand, floating over the bin it came out of.
    final held = play.holding;
    if (held != null) {
      final at = Offset(m.pad + held * m.wide + m.wide / 2,
          m.floor - (m.tallest + 1) * m.measure);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: at, width: m.wide * 0.5, height: m.measure - 2),
            Radius.circular(m.measure * 0.22)),
        Paint()..color = Palette.held,
      );
    }
    if (!m.roomy) return;
    _word(
        canvas,
        held == null
            ? 'tap a bin two ahead of another to take a measure out of it'
            : 'tap a bin at least two behind to put the measure in',
        Offset(size.width / 2, size.height - 8),
        Palette.inkDim,
        size,
        11);
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
  bool shouldRepaint(AlmsView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}
