import 'dart:math';

import 'package:flutter/material.dart';

import '../strip/play.dart';
import '../strip/rules.dart';
import 'palette.dart';

/// Where the strip lies in a board of a given size: across the middle
/// on its thread, with the repeats marked underneath.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final pad = min(bare ? 12.0 : 18.0, size.width * 0.06);
    final beads = play.level.beads;
    step = max(2.0, (size.width - 2 * pad) / beads);
    bead = max(1.5, min(step * 0.42, bare ? 40.0 : 26.0));
    left = (size.width - step * beads) / 2 + step / 2;
    middle = size.height * (bare ? 0.5 : 0.36);
    repeatTop = middle + bead * 2.4;
  }

  final Play play;
  final Size size;
  final bool bare;

  /// How far apart the beads sit, and how big each is.
  late final double step;
  late final double bead;
  late final double left;
  late final double middle;

  /// Where the marks for the repeats start.
  late final double repeatTop;

  Offset at(int which) => Offset(left + which * step, middle);

  /// Which bead lies under [where], or null when none is near enough.
  int? under(Offset where) {
    for (var i = 0; i < play.level.beads; i++) {
      if ((at(i) - where).distance <= max(bead * 1.4, 18.0)) return i;
    }
    return null;
  }

  bool get roomy => bead >= 10;
}

/// The strip of beads and the repeats it has.
class StripView extends CustomPainter {
  const StripView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The bead the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the strip alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final beads = play.beads;

    // The thread.
    canvas.drawLine(
      m.at(0).translate(-m.bead, 0),
      m.at(beads.length - 1).translate(m.bead, 0),
      Paint()
        ..color = Palette.thread
        ..strokeWidth = max(1.4, m.bead * 0.16),
    );

    for (var i = 0; i < beads.length; i++) {
      final at = m.at(i);
      canvas.drawCircle(
        at,
        m.bead,
        Paint()
          ..color = beads[i] == Rules.light ? Palette.lightBead : Palette.darkBead,
      );
      canvas.drawCircle(
        at,
        m.bead,
        Paint()
          ..color = Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.0, m.bead * 0.08),
      );
      if (i == pointing) {
        canvas.drawCircle(
          at,
          m.bead * 1.45,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.6, m.bead * 0.14),
        );
      }
    }

    if (bare) return;

    // The repeats: a row of numbers, lit when the strip has them.
    final periods = play.periods;
    final wanted = {play.level.first, play.level.second, play.level.forced};
    for (var p = 1; p <= play.level.beads; p++) {
      final has = periods.contains(p);
      final at = Offset(m.left + (p - 1) * m.step, m.repeatTop);
      if (wanted.contains(p)) {
        canvas.drawCircle(
          at,
          m.bead * 0.8,
          Paint()
            ..color = has ? Palette.gold : Palette.line
            ..style = has ? PaintingStyle.fill : PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      } else if (has) {
        canvas.drawCircle(at, m.bead * 0.5, Paint()..color = Palette.inkDim);
      }
      _word(
        canvas,
        '$p',
        at,
        min(m.bead * 0.9, 13.0),
        wanted.contains(p) && has ? Palette.night : Palette.inkDim,
      );
    }
    if (m.roomy) {
      _word(
        canvas,
        'the repeats it has: ${Rules.tellPeriods(periods)}',
        Offset(size.width / 2, m.repeatTop + m.bead * 2.2),
        12,
        Palette.inkDim,
      );
    }
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
  bool shouldRepaint(StripView old) =>
      old.play != play || old.pointing != pointing;
}
