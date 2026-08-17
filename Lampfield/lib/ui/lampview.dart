import 'dart:math';

import 'package:flutter/material.dart';

import '../lamp/play.dart';
import '../lamp/rules.dart';
import 'palette.dart';

/// Where the lamps stand in a board of a given size: a row across, with
/// a mark under each for what the reader makes of the message when that
/// lamp goes out.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    pad = bare ? size.width * 0.05 : 12.0;
    across = (size.width - pad * 2) / Rules.lamps;
    final words = bare ? 0.0 : 30.0;
    radius = min(across * (bare ? 0.44 : 0.34), (size.height - words) * 0.13);
    lamps = (bare ? size.height * 0.5 : (size.height - words) * 0.34);
    marks = lamps + radius * 2.6;
  }

  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double pad, across, radius, lamps, marks;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 150 && size.width >= 240;

  Offset lampAt(int lamp) =>
      Offset(pad + (lamp - 0.5) * across, lamps);

  /// The lamp a tap means, counting from 1, or null.
  int? lampNear(Offset at) {
    if (at.dx < pad || at.dx > size.width - pad) return null;
    final lamp = ((at.dx - pad) / across).floor() + 1;
    return lamp < 1 || lamp > Rules.lamps ? null : lamp;
  }
}

/// The lamps, lit and dark, and what the reader makes of each of them
/// going out.
class LampView extends CustomPainter {
  const LampView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the lamps alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);
    canvas.drawLine(
      Offset(m.pad, m.lamps + m.radius * 1.5),
      Offset(size.width - m.pad, m.lamps + m.radius * 1.5),
      Paint()
        ..color = Palette.line
        ..strokeWidth = bare ? 3 : 1.6,
    );
    for (var lamp = 1; lamp <= Rules.lamps; lamp++) {
      final lit = play.message[lamp - 1] == 1;
      final at = m.lampAt(lamp);
      if (lit) {
        canvas.drawCircle(at, m.radius * 1.7,
            Paint()..color = Palette.flame.withValues(alpha: 0.16));
      }
      canvas.drawCircle(
          at, m.radius, Paint()..color = lit ? Palette.flame : Palette.cold);
      canvas.drawCircle(
        at,
        m.radius,
        Paint()
          ..color = pointing == lamp ? Palette.shown : Palette.night
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : (pointing == lamp ? 2.6 : 1.4),
      );
      if (bare) continue;
      _word(canvas, '$lamp', at, lit ? Palette.night : Palette.inkDim, size,
          m.radius * 0.9);
      // What the reader makes of the message with this lamp out.
      final held = play.holds(lamp);
      final mark = Offset(at.dx, m.marks);
      canvas.drawCircle(mark, m.radius * 0.42,
          Paint()..color = held ? Palette.mended : Palette.misfit);
    }
    if (bare || !m.roomy) return;
    _word(
        canvas,
        'a green mark means the reader mends the message when that lamp '
        'goes out',
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
  bool shouldRepaint(LampView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}
