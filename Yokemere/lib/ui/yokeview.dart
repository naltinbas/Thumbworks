import 'dart:math';

import 'package:flutter/material.dart';

import '../yoke/play.dart';
import '../yoke/rules.dart';
import 'palette.dart';

/// Where the two rows stand in a board of a given size.
///
/// The near row along the top and the off row below it, five places
/// across, with a yoke drawn between each pair and its pull written on
/// the timber.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 20.0;
    final room = Size(
      max(size.width - 16, 8),
      max(size.height - words - 16, 8),
    );
    place = room.width / Rules.oxen;
    left = 8;
    final tall = min(room.height, place * 3.4);
    top = 8 + max((room.height - tall) / 2, 0);
    ox = max(min(place * 0.30, bare ? 30.0 : 20.0), 3);
    yokeTop = top + tall * 0.34;
    yokeFoot = top + tall * 0.66;
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double place, left, top, ox, yokeTop, yokeFoot;

  /// Whether there is room for words under the yard.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  double middleOf(int at) => left + (at + 0.5) * place;

  Offset nearAt(int at) => Offset(middleOf(at), yokeTop - ox * 1.4);

  Offset offAt(int at) => Offset(middleOf(at), yokeFoot + ox * 1.4);

  /// The place a tap means, or null when it lands on none.
  int? placeNear(Offset touch) {
    for (var at = 0; at < Rules.oxen; at++) {
      final middle = Offset(middleOf(at), (yokeTop + yokeFoot) / 2);
      if ((touch - middle).dx.abs() < place * 0.46 &&
          (touch.dy - middle.dy).abs() < (yokeFoot - yokeTop) * 0.5 + ox * 2.2) {
        return at;
      }
    }
    return null;
  }
}

/// The yard, its two rows and the yokes between them.
class YokeView extends CustomPainter {
  const YokeView({
    required this.play,
    this.pointing,
    this.showCrossed = false,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The two places the show-me wants swapped, or null.
  final (int, int)? pointing;

  /// Whether to mark the pairs that are crossed, which is the reason a
  /// team is not yet the best it could be.
  final bool showCrossed;

  final TextStyle labels;

  /// Whether to draw the yard alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);

    for (var at = 0; at < Rules.oxen; at++) {
      final crossedHere = play.crossedWith(at).isNotEmpty;
      final near = m.nearAt(at);
      final off = m.offAt(at);

      // The yoke itself, with the pull of the pair written on it.
      canvas.drawLine(
        Offset(near.dx, m.yokeTop),
        Offset(off.dx, m.yokeFoot),
        Paint()
          ..color = showCrossed && crossedHere ? Palette.crossed : Palette.yoke
          ..strokeWidth = bare ? 5 : 3.2,
      );
      if (!bare) {
        final pull = Rules.near[at] * play.oxAt(at);
        _word(canvas, '$pull', Offset(near.dx, (m.yokeTop + m.yokeFoot) / 2),
            showCrossed && crossedHere ? Palette.crossed : Palette.inkDim,
            size, m.ox * 0.7);
      }

      // The near ox, which never moves, and the off ox, which does.
      canvas.drawCircle(near, m.ox, Paint()..color = Palette.nearOx);
      canvas.drawCircle(off, m.ox, Paint()..color = Palette.offOx);
      if (!bare) {
        _word(canvas, '${Rules.near[at]}', near, Palette.ink, size,
            m.ox * 1.05);
        _word(canvas, '${play.oxAt(at)}', off, Palette.night, size,
            m.ox * 1.05);
      }

      final lit = play.held == at ||
          (pointing != null && (pointing!.$1 == at || pointing!.$2 == at));
      if (!bare && lit) {
        canvas.drawCircle(
          off,
          m.ox * 1.45,
          Paint()
            ..color = play.held == at ? Palette.ink : Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    if (bare || !m.roomy) return;
    _word(
      canvas,
      play.anyCrossed
          ? 'the team pulls ${play.pull}; some pairs are still crossed'
          : 'the team pulls ${play.pull}; nothing is crossed',
      Offset(size.width / 2, size.height - 8),
      play.anyCrossed ? Palette.inkDim : Palette.matched,
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
  bool shouldRepaint(YokeView old) =>
      old.play.mark != play.mark ||
      old.play.held != play.held ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showCrossed != showCrossed ||
      old.bare != bare;
}
