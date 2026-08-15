import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mere/play.dart';
import '../mere/rules.dart';
import 'palette.dart';

/// Where the pads lie on the board, so the screen and the tests
/// can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    var wide = 2;
    var lowest = -1;
    for (final (x, y) in play.reach.army) {
      wide = math.max(wide, x.abs() + 1);
      lowest = math.min(lowest, y - 1);
    }
    cols = 2 * wide + 1;
    top = play.reach.reach;
    bottom = lowest;
    rows = top - bottom + 1;
    pitch = math.min(room.width * 0.86 / cols, room.height * 0.94 / rows);
    origin = Offset(
      (room.width - pitch * cols) / 2,
      (room.height - pitch * rows) / 2,
    );
    this.wide = wide;
  }

  final Play play;

  late final int wide;
  late final int cols;
  late final int rows;

  /// The highest and lowest rows drawn.
  late final int top;
  late final int bottom;

  late final double pitch;
  late final Offset origin;

  /// The middle of a pad.
  Offset at(Pad pad) => Offset(
        origin.dx + (pad.$1 + wide + 0.5) * pitch,
        origin.dy + (top - pad.$2 + 0.5) * pitch,
      );

  bool onBoard(Pad pad) =>
      pad.$1.abs() <= wide && pad.$2 >= bottom && pad.$2 <= top;

  /// The pad under a touch, or null off the board.
  Pad? under(Offset touch) {
    final col = ((touch.dx - origin.dx) / pitch).floor();
    final row = ((touch.dy - origin.dy) / pitch).floor();
    if (col < 0 || col >= cols || row < 0 || row >= rows) return null;
    return (col - wide, top - row);
  }

  /// The line of the reeds, between row one and row nought.
  double get reedsY => origin.dy + top * pitch;
}

/// The mere itself: pads, reeds, frogs, the aim, and the rings
/// of a pick or a pointer.
class MereView extends CustomPainter {
  MereView({required this.play, this.pointing, required this.labels});

  final Play play;
  final Leap? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;

    // The water.
    final water = Rect.fromLTWH(
      metrics.origin.dx,
      metrics.origin.dy,
      pitch * metrics.cols,
      pitch * metrics.rows,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(water.inflate(pitch * 0.1), Radius.circular(pitch * 0.3)),
      Paint()..color = Palette.water,
    );

    // The pads.
    for (var y = metrics.bottom; y <= metrics.top; y++) {
      for (var x = -metrics.wide; x <= metrics.wide; x++) {
        final at = metrics.at((x, y));
        canvas.drawCircle(at, pitch * 0.4, Paint()..color = Palette.pad);
        canvas.drawCircle(
          at,
          pitch * 0.4,
          Paint()
            ..color = Palette.padRim
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1, pitch * 0.03),
        );
      }
    }

    // The reeds along the line, and the reaches numbered.
    final reeds = Paint()
      ..color = Palette.reeds
      ..strokeWidth = math.max(2, pitch * 0.08)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i <= metrics.cols * 3; i++) {
      final x = water.left + i * pitch / 3;
      final lean = (i % 3 - 1) * pitch * 0.06;
      canvas.drawLine(
        Offset(x, metrics.reedsY + pitch * 0.12),
        Offset(x + lean, metrics.reedsY - pitch * 0.12),
        reeds,
      );
    }
    for (var y = 1; y <= metrics.top; y++) {
      _write(
        canvas,
        '$y',
        Offset(water.right + pitch * 0.42, metrics.at((0, y)).dy),
        labels.copyWith(
          color: y == metrics.top ? Palette.aim : Palette.inkDim,
          fontSize: math.max(9, pitch * 0.34),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // The aim.
    final aimAt = metrics.at(play.rules.aim);
    canvas.drawCircle(
      aimAt,
      pitch * 0.4,
      Paint()
        ..color = Palette.aim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, pitch * 0.06),
    );
    if (!play.frogs.contains(play.rules.aim)) {
      _write(
        canvas,
        '1',
        aimAt,
        labels.copyWith(
          color: Palette.aim,
          fontSize: pitch * 0.36,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    // The frogs.
    for (final frog in play.frogs) {
      if (!metrics.onBoard(frog)) continue;
      final at = metrics.at(frog);
      canvas.drawCircle(at, pitch * 0.34, Paint()..color = Palette.frogDark);
      canvas.drawCircle(
        at + Offset(0, -pitch * 0.03),
        pitch * 0.29,
        Paint()..color = Palette.frog,
      );
      for (final side in [-1, 1]) {
        canvas.drawCircle(
          at + Offset(side * pitch * 0.12, -pitch * 0.14),
          pitch * 0.06,
          Paint()..color = Palette.frogEye,
        );
      }
      if (play.picked == frog) {
        canvas.drawCircle(
          at,
          pitch * 0.44,
          Paint()
            ..color = Palette.picked
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, pitch * 0.06),
        );
      }
    }

    // The pads a picked frog may leap into.
    if (play.picked != null) {
      for (final leap in play.openToPicked) {
        canvas.drawCircle(
          metrics.at(leap.to),
          pitch * 0.2,
          Paint()..color = Palette.picked.withValues(alpha: 0.35),
        );
      }
    }

    // The pointer's leap.
    final aim = pointing;
    if (aim != null) {
      final ring = Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, pitch * 0.06);
      canvas.drawCircle(metrics.at(aim.from), pitch * 0.46, ring);
      canvas.drawCircle(metrics.at(aim.to), pitch * 0.46, ring);
      canvas.drawLine(metrics.at(aim.from), metrics.at(aim.to),
          Paint()
            ..color = Palette.shown
            ..strokeWidth = math.max(1.5, pitch * 0.04));
      canvas.drawCircle(
        metrics.at(aim.over),
        pitch * 0.4,
        Paint()
          ..color = Palette.gone
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, pitch * 0.04),
      );
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(MereView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a reach as it stands.
String whyWords(Play play) {
  final reach = play.reach;
  final note = reach.note == null ? '' : ' ${reach.note}';
  if (!reach.winnable) {
    return 'Give the pad aimed at the weight one, and every other pad '
        'one over the golden ratio to the power of its distance from '
        'it. A leap toward the aim keeps an army\'s weight exactly, '
        'since one over phi and one over phi squared make one, and '
        'every other leap loses. The whole pond below the reeds, added '
        'up out to the edge of the world, weighs exactly one against '
        'the fifth reach, so any army you could set down weighs less, '
        'and a frog on the aim would weigh one by itself. The count '
        'tried every leap and found no road.$note';
  }
  return 'The roads are counted by walking every order of leaps that '
      'keeps the army\'s weight at one or above, since a leap toward '
      'the aim keeps it exactly and every other leap loses, and the '
      'weights are held to a second voice: added up exactly in the '
      'golden ratio\'s own arithmetic, where one over phi and one over '
      'phi squared make one. ${reach.roads == 1 ? 'One road lands' : '${reach.roads} roads land'} '
      'this reach in ${reach.leaps} leap${reach.leaps == 1 ? '' : 's'}.$note';
}
