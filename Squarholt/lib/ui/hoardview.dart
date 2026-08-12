import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hoard/play.dart';
import '../hoard/rules.dart';
import 'palette.dart';

/// Where the two tiles stand, shared by the painter and the
/// screen, so what is drawn is exactly what the dials say.
class Metrics {
  Metrics(this.play, Size room) {
    final across = play.a + play.b + 2.5;
    final tall = math.max(play.a, play.b) + 1.5;
    unit = math.min(
      room.width * 0.9 / across,
      room.height * 0.62 / tall,
    );
    ground = room.height * 0.62;
    final wide = (play.a + play.b) * unit + unit * 1.2;
    aLeft = (room.width - wide) / 2;
    bLeft = aLeft + play.a * unit + unit * 1.2;
  }

  final Play play;

  late final double unit;
  late final double ground;
  late final double aLeft;
  late final double bLeft;

  /// The square a tile of [side] takes, standing at [left].
  Rect squareOf(int side, double left) => Rect.fromLTWH(
        left,
        ground - side * unit,
        side * unit,
        side * unit,
      );
}

/// The two tiles, drawn: every unit of both squares, and the
/// sum they pay told beneath.
class HoardView extends CustomPainter {
  HoardView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The turn the show-me points at, or null.
  final (bool, bool)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final unit = metrics.unit;

    _tiles(canvas, metrics.squareOf(play.a, metrics.aLeft), play.a,
        unit, Palette.copper, Palette.copperRim);
    _tiles(canvas, metrics.squareOf(play.b, metrics.bLeft), play.b,
        unit, Palette.slate, Palette.slateRim);

    // The ground line both squares stand on.
    canvas.drawLine(
      Offset(metrics.aLeft - unit * 0.5, metrics.ground),
      Offset(metrics.bLeft + play.b * unit + unit * 0.5,
          metrics.ground),
      Paint()
        ..color = Palette.line
        ..strokeWidth = 2.4,
    );

    // The plus between the squares.
    _text(
      canvas,
      '+',
      Offset(
        metrics.aLeft + play.a * unit + unit * 0.6,
        metrics.ground - unit * 0.8,
      ),
      labels.copyWith(color: Palette.inkDim, fontSize: unit * 0.9),
    );

    // The widths, under their squares.
    _text(
      canvas,
      '${play.a}',
      Offset(metrics.aLeft + play.a * unit / 2,
          metrics.ground + unit * 0.7),
      labels.copyWith(color: Palette.inkDim, fontSize: unit * 0.8),
    );
    _text(
      canvas,
      '${play.b}',
      Offset(metrics.bLeft + play.b * unit / 2,
          metrics.ground + unit * 0.7),
      labels.copyWith(color: Palette.inkDim, fontSize: unit * 0.8),
    );

    // The sum they pay, against the hoard.
    final paid = play.paid;
    final told =
        '${play.a * play.a} + ${play.b * play.b} = $paid';
    _text(
      canvas,
      told,
      Offset(size.width / 2, metrics.ground + unit * 2.1),
      labels.copyWith(
        color: play.isDone
            ? Palette.good
            : paid > play.hoard.target
                ? Palette.bad
                : Palette.ink,
        fontSize: math.min(unit * 1.05, size.width * 0.07),
        fontWeight: FontWeight.w800,
      ),
    );

    // The pointed dial.
    final aim = pointing;
    if (aim != null) {
      final (first, _) = aim;
      final square = first
          ? metrics.squareOf(play.a, metrics.aLeft)
          : metrics.squareOf(play.b, metrics.bLeft);
      canvas.drawRect(
        square.inflate(unit * 0.3),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }
  }

  void _tiles(Canvas canvas, Rect square, int side, double unit,
      Color fill, Color rim) {
    for (var y = 0; y < side; y++) {
      for (var x = 0; x < side; x++) {
        final tile = Rect.fromLTWH(
          square.left + x * unit,
          square.top + y * unit,
          unit,
          unit,
        ).deflate(unit * 0.05);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              tile, Radius.circular(unit * 0.12)),
          Paint()
            ..color = play.isDone ? Palette.paidGold : fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              tile, Radius.circular(unit * 0.12)),
          Paint()
            ..color = rim
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _text(
      Canvas canvas, String words, Offset at, TextStyle style) {
    final drawn = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    drawn.paint(canvas, at - Offset(drawn.width / 2, drawn.height / 2));
  }

  @override
  bool shouldRepaint(HoardView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the hoard at hand.
String whyWords(Play play) {
  final hoard = play.hoard;
  final note = hoard.note == null ? '' : ' ${hoard.note}';
  if (!hoard.winnable) {
    return 'A square tile pays nought or one past a four-times, '
        'never two or three past: whole rows of four, then a '
        'corner of nought or one. Two tiles together reach two '
        'past at the very most, and ${hoard.target} sits three '
        'past, ${hoard.target ~/ 4} fours and three. The dials '
        'were swept whole, every pair to ${Rules.widest} by '
        '${Rules.widest}, and no pair pays it.$note';
  }
  return 'A hoard is paid two ways that share nothing: the dials '
      'swept whole, every pair of tiles to ${Rules.widest} by '
      '${Rules.widest}, and the remainder read with no searching, '
      'squares paying nought or one past a four-times. Fermat\'s '
      'law holds every prime one past a four-times to exactly one '
      'writing, swept under a hundred. ${hoard.ways} '
      'writing${hoard.ways == 1 ? '' : 's'} '
      'land${hoard.ways == 1 ? 's' : ''} this hoard.$note';
}
