import 'dart:math';

import 'package:flutter/material.dart';

import '../glint/level.dart';
import '../glint/play.dart';
import '../glint/rules.dart';
import 'palette.dart';

/// Where the mirror sits in a board of a given size.
///
/// The glass runs across the middle with a peg every pace, the lamp and
/// the eye stand above it, and when the board is folding itself open the
/// eye's reflection is drawn the same distance below.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false, this.showFold = false}) {
    final words = bare ? 0.0 : 20.0;
    final room = Size(
      max(size.width - 20, 8),
      max(size.height - words - 20, 8),
    );
    // Above the glass the picture is as tall as the sky; with the fold
    // open it is that again below.
    final rows = showFold ? Rules.sky * 2 : Rules.sky;
    if (bare) {
      // The mark carries only the light itself, so it is scaled to the
      // span from the lamp to the eye and set in the middle of the frame.
      const span = Level.eyeX - Level.lampX + 2;
      pace = max(min(room.width / span, room.height / (Level.lampY + 2)), 2);
      final middle = (Level.lampX + Level.eyeX) / 2;
      left = 10 + room.width / 2 - middle * pace;
      glass = 10 + (room.height + Level.lampY * pace) / 2;
    } else {
      pace =
          max(min(room.width / (Rules.mirror - 1), room.height / (rows + 1)), 2);
      left = 10 + (room.width - pace * (Rules.mirror - 1)) / 2;
      glass = 10 + (showFold ? room.height / 2 : room.height - pace * 0.6);
    }
    peg = max(min(pace * 0.16, bare ? 12.0 : 7.0), 1.5);
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  /// Whether the eye's reflection and the straight run are drawn.
  final bool showFold;

  late final double pace, left, glass, peg;

  /// Whether there is room for words under the board.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  Offset at(num x, num y) => Offset(left + x * pace, glass - y * pace);

  /// The peg of the mirror a tap means, whether or not it is exact: a
  /// tap anywhere on the glass slides the bounce one pace towards it.
  int towards(Offset touch) {
    final x = ((touch.dx - left) / pace).round();
    return x.clamp(0, Rules.mirror - 1);
  }
}

/// The mirror, the lamp, the eye and the light between them.
class GlintView extends CustomPainter {
  const GlintView({
    required this.play,
    this.pointing,
    this.showFold = false,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The peg the show-me points towards, or null.
  final int? pointing;

  /// Whether to fold the board open, which is the proof of the last ask.
  final bool showFold;

  final TextStyle labels;

  /// Whether to draw the light alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare, showFold: showFold);
    final lamp = m.at(Level.lampX, Level.lampY);
    final eye = m.at(Level.eyeX, Level.eyeY);
    final hit = m.at(play.bounce, 0);

    // The glass, with a peg every pace.
    canvas.drawLine(
      m.at(0, 0),
      m.at(Rules.mirror - 1, 0),
      Paint()
        ..color = Palette.glass
        ..strokeWidth = bare ? 4 : 2.4,
    );
    if (!bare) {
      for (final p in Rules.bounces) {
        canvas.drawCircle(m.at(p, 0), m.peg * 0.6,
            Paint()..color = Palette.peg);
      }
    }

    // The board folded open: the eye's reflection, and the straight run
    // to it, which no bent path can beat.
    if (showFold) {
      final under = m.at(Level.eyeX, -Level.eyeY);
      canvas.drawLine(
        lamp,
        under,
        Paint()
          ..color = Palette.fold
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        hit,
        under,
        Paint()
          ..color = Palette.beam.withValues(alpha: 0.35)
          ..strokeWidth = 1.6,
      );
      canvas.drawCircle(under, m.peg * 1.3,
          Paint()..color = Palette.fold);
      if (!bare) {
        _word(canvas, 'the eye, folded under', under + Offset(0, m.peg * 3),
            Palette.fold, size, 10);
      }
    }

    // The light: out to the glass and on to the eye.
    final beam = Paint()
      ..color = Palette.beam
      ..strokeWidth = bare ? 4 : 2.6;
    canvas.drawLine(lamp, hit, beam);
    canvas.drawLine(hit, eye, beam);

    // The lamp, the eye and the bounce.
    canvas.drawCircle(lamp, m.peg * 1.6, Paint()..color = Palette.lamp);
    canvas.drawCircle(eye, m.peg * 1.6, Paint()..color = Palette.eye);
    canvas.drawCircle(hit, m.peg * 1.2, Paint()..color = Palette.beam);
    canvas.drawCircle(
      hit,
      m.peg * 2.1,
      Paint()
        ..color = play.even ? Palette.good : Palette.beam
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (!bare && pointing != null && pointing != play.bounce) {
      canvas.drawCircle(
        m.at(pointing!, 0),
        m.peg * 2.1,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (bare) return;
    _word(canvas, 'lamp', lamp + Offset(0, -m.peg * 3.2), Palette.lamp, size,
        10);
    _word(canvas, 'eye', eye + Offset(0, -m.peg * 3.2), Palette.eye, size, 10);
    if (!m.roomy) return;
    final whole = play.paces;
    _word(
      canvas,
      whole == null
          ? 'the two legs are no whole number of paces'
          : 'the path is $whole paces',
      Offset(size.width / 2, size.height - 8),
      Palette.inkDim,
      size,
      10,
    );
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
  bool shouldRepaint(GlintView old) =>
      old.play.bounce != play.bounce ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showFold != showFold ||
      old.bare != bare;
}
