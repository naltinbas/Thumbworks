import 'dart:math';

import 'package:flutter/material.dart';

import '../ring/play.dart';
import '../ring/rules.dart';
import 'palette.dart';

/// Where the coins sit in a board of a given size: units to pixels, the
/// middle coin at the centre.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 26.0 : 0.0;
    centre = Offset(size.width / 2, (size.height - strip) / 2);
    scale = (min(size.width, size.height - strip) / 2 - 8) / (play.middle + 2 * play.ring);
  }

  final Play play;
  final Size size;
  late final Offset centre;
  late final double scale;

  /// The centre of ring coin [i] of the most that fit.
  Offset ringAt(int i) {
    final (x, y) = Rules.centre(play.middle, play.ring, play.fit, i);
    return centre + Offset(x, -y) * scale;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The middle coin, the ring coins that fit, and the turn to spare.
class RingView extends CustomPainter {
  const RingView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the coins only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final middleR = play.middle * m.scale, ringR = play.ring * m.scale;
    // The ring coins are set at equal angles from the top going
    // clockwise; the spare, if any, is drawn as an arc on the middle
    // coin's rim between the last coin and the first, so it is put after
    // the last coin: the coins are turned back by half the spare so the
    // gap sits at the top and the picture is even.
    final fit = play.fit;
    final each = Rules.span(play.middle, play.ring);
    final spare = 2 * pi - fit * each;
    canvas.drawCircle(m.centre, middleR, Paint()..color = Palette.middleFace);
    canvas.drawCircle(
      m.centre,
      middleR,
      Paint()
        ..color = Palette.middle
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 5 : 2.5,
    );
    for (var i = 0; i < fit; i++) {
      // Coin i sits at angle spare/2 + each/2 + i*each from the top.
      final a = spare / 2 + each / 2 + i * each;
      final c = m.centre + Offset(sin(a), -cos(a)) * (middleR + ringR);
      canvas.drawLine(m.centre, c, Paint()..color = Palette.spoke..strokeWidth = 1);
      canvas.drawCircle(c, ringR, Paint()..color = Palette.ringFace);
      canvas.drawCircle(
        c,
        ringR,
        Paint()
          ..color = Palette.ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 4 : 2,
      );
    }
    if (spare > 1e-9) {
      canvas.drawArc(
        Rect.fromCircle(center: m.centre, radius: middleR),
        -pi / 2 - spare / 2,
        spare,
        false,
        Paint()
          ..color = Palette.spare
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 7 : 4,
      );
    }
    if (bare || !m.roomy) return;
    _word(canvas, '${play.middle}', m.centre, Palette.middle, size);
    _word(canvas, '$fit fit, ${play.spare.toStringAsFixed(1)} degrees to spare, each ${play.each.toStringAsFixed(1)}', Offset(size.width / 2, size.height - 12), Palette.inkDim, size);
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
  bool shouldRepaint(RingView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}
