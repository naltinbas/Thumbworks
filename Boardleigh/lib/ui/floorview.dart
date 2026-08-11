import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../floor/play.dart';
import 'palette.dart';

/// Where every cell lies, shared by the painter and the hit-testing,
/// so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    cell = math.min(
      math.min(width * 0.9 / play.room.wide,
          height * 0.82 / play.room.high),
      76.0,
    );
    left = (width - play.room.wide * cell) / 2;
    top = (height - play.room.high * cell) / 2;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double cell;
  late final double left;
  late final double top;

  Rect cellRect(int at) => Rect.fromLTWH(
        left + (at % play.room.wide) * cell,
        top + (at ~/ play.room.wide) * cell,
        cell,
        cell,
      );

  /// The cell under a touch, or -1.
  int cellAt(Offset touch) {
    final col = ((touch.dx - left) / cell).floor();
    final row = ((touch.dy - top) / cell).floor();
    if (col < 0 ||
        row < 0 ||
        col >= play.room.wide ||
        row >= play.room.high) {
      return -1;
    }
    final at = row * play.room.wide + col;
    return play.rules.inRoom(at) ? at : -1;
  }
}

/// The floor, drawn.
class FloorView extends CustomPainter {
  FloorView({
    required this.play,
    required this.armed,
    this.pointing,
    this.showColours = false,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The cell armed for a plank, or -1.
  final int armed;

  /// The plank being pointed at, or null.
  final (int, int)? pointing;

  /// Whether to tint the two colours and count them.
  final bool showColours;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var at = 0; at < play.room.wide * play.room.high; at++) {
      if (!play.rules.inRoom(at)) continue;
      final rect = metrics.cellRect(at);
      canvas.drawRect(rect, Paint()..color = Palette.bare);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Palette.bareEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      if (showColours) {
        final dark =
            (at % play.room.wide + at ~/ play.room.wide).isEven;
        canvas.drawRect(
          rect,
          Paint()
            ..color = dark ? Palette.darkTint : Palette.lightTint,
        );
      }
    }

    for (final (one, other) in play.planks) {
      final rect = metrics
          .cellRect(one)
          .expandToInclude(metrics.cellRect(other))
          .deflate(metrics.cell * 0.08);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect, Radius.circular(metrics.cell * 0.14)),
        Paint()..color = Palette.plank,
      );
      // The grain, along the plank.
      final along = (one % play.room.wide) != (other % play.room.wide);
      for (var vein = 1; vein <= 2; vein++) {
        final t = vein / 3;
        canvas.drawLine(
          along
              ? Offset(rect.left + 6,
                  rect.top + rect.height * t)
              : Offset(rect.left + rect.width * t, rect.top + 6),
          along
              ? Offset(rect.right - 6,
                  rect.top + rect.height * t)
              : Offset(
                  rect.left + rect.width * t, rect.bottom - 6),
          Paint()
            ..color = Palette.plankGrain
            ..strokeWidth = 1.2,
        );
      }
    }

    if (armed >= 0) {
      canvas.drawRect(
        metrics.cellRect(armed).deflate(1.6),
        Paint()
          ..color = Palette.armed
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
    final pointed = pointing;
    if (pointed != null) {
      final rect = metrics
          .cellRect(pointed.$1)
          .expandToInclude(metrics.cellRect(pointed.$2))
          .deflate(metrics.cell * 0.08);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect, Radius.circular(metrics.cell * 0.14)),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    if (showColours && showWords) {
      final (dark, light) = play.rules.colours();
      final words = TextPainter(
        text: TextSpan(
          text: '$dark dark, $light light',
          style: labels.copyWith(
            color: dark == light ? Palette.good : Palette.bad,
            fontSize: metrics.cell * 0.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        Offset((metrics.width - words.width) / 2,
            metrics.top + play.room.high * metrics.cell + 10),
      );
    }
  }

  @override
  bool shouldRepaint(FloorView old) =>
      old.play != play ||
      old.armed != armed ||
      old.pointing != pointing ||
      old.showColours != showColours;
}

/// The words the why speaks, from the room at hand.
String whyWords(Play play) {
  final room = play.room;
  final note = room.note == null ? '' : ' ${room.note}';
  final (dark, light) = play.rules.colours();
  if (!room.winnable) {
    return 'Every plank covers one dark cell and one light, so a '
        'floored room keeps its colours even. This one holds $dark '
        'dark and $light light: the colours are shown, and the count '
        'of every laying found none.$note';
  }
  return 'The colours are even, $dark and $light, as any floorable '
      'room\'s must be, and the count found ${room.ways} full '
      'laying${room.ways == 1 ? '' : 's'} of this one. A plank that '
      'strands the rest is called out the moment it lands.$note';
}
