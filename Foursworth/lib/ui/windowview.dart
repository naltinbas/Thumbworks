import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../window/play.dart';
import '../window/rules.dart';
import 'palette.dart';

/// Where every window sits, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    slot = math.min(
      room.width * 0.86 / play.windows.length,
      room.height * 0.2,
    );
    left = (room.width - slot * play.windows.length) / 2;
    top = room.height * 0.05;
  }

  final Play play;

  late final double slot;
  late final double left;
  late final double top;

  /// A window's frame.
  Rect frameOf(int at) => Rect.fromLTWH(
        left + at * slot + slot * 0.08,
        top,
        slot * 0.84,
        slot * 1.1,
      );

  /// The window under a touch, or -1 for the wall.
  int windowUnder(Offset touch) {
    for (var at = 0; at < play.windows.length; at++) {
      if (frameOf(at).inflate(slot * 0.06).contains(touch)) {
        return at;
      }
    }
    return -1;
  }
}

/// The house, drawn: the windows glowing to their faces, and
/// the whole walk written beneath, darkness landing gold.
class WindowView extends CustomPainter {
  WindowView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The window the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final slot = metrics.slot;

    // The windows.
    for (var at = 0; at < play.windows.length; at++) {
      final frame = metrics.frameOf(at);
      final face = play.windows[at];
      final lit = face / Rules.brightest;
      canvas.drawRRect(
        RRect.fromRectAndRadius(frame, Radius.circular(slot * 0.1)),
        Paint()
          ..color = Color.lerp(Palette.dim, Palette.glow, lit)!,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(frame, Radius.circular(slot * 0.1)),
        Paint()
          ..color = Palette.frame
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
      canvas.drawLine(
        frame.topCenter + Offset(0, frame.height * 0.5),
        frame.bottomCenter - Offset(0, frame.height * 0.5),
        Paint()..color = Palette.frame..strokeWidth = 1.6,
      );
      canvas.drawLine(
        frame.centerLeft + Offset(frame.width * 0.5, 0),
        frame.centerRight - Offset(frame.width * 0.5, 0),
        Paint()..color = Palette.frame..strokeWidth = 1.6,
      );
      final wear = TextPainter(
        text: TextSpan(
          text: '$face',
          style: labels.copyWith(
            color: lit > 0.55 ? Palette.night : Palette.ink,
            fontSize: slot * 0.44,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      wear.paint(canvas,
          frame.center - Offset(wear.width / 2, wear.height / 2));

      if (pointing == at) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              frame.inflate(slot * 0.1), Radius.circular(slot * 0.14)),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The walk, written line by line.
    final road = play.road;
    final roadTop = metrics.top + slot * 1.5;
    final lineHigh =
        math.min(slot * 0.5, (size.height - roadTop) / 9);
    final circling = play.turns < 0;
    final shown = circling ? 5 : math.min(road.length, 9);
    for (var step = 0; step < shown; step++) {
      final last = !circling && step == road.length - 1;
      final words = road[step].join(' · ');
      final drawn = TextPainter(
        text: TextSpan(
          text: circling && step == shown - 1
              ? '$words and round again'
              : words,
          style: labels.copyWith(
            color: last ? Palette.rest : Palette.ink,
            fontSize: lineHigh * 0.52,
            fontWeight: last ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      drawn.paint(
        canvas,
        Offset(size.width / 2 - drawn.width / 2,
            roadTop + lineHigh * step),
      );
    }
  }

  @override
  bool shouldRepaint(WindowView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the house at hand.
String whyWords(Play play) {
  final house = play.house;
  final note = house.note == null ? '' : ' ${house.note}';
  if (!house.winnable) {
    return 'Watch the parities alone: odd or even is all the '
        'differences care about, and three windows not all alike '
        'tread the ring nought-one-one, one-nought-one, '
        'one-one-nought, round and round without a landing. Only '
        'all-alike escapes, going dark in a single turn. The '
        'sweep dialled all 512 threes and the 504 not alike '
        'circled, every one.$note';
  }
  return 'The turns are counted two ways that share nothing: the '
      'walk itself, difference upon difference written under the '
      'windows, and the halving law, four turns leaving every '
      'face even and evens shrinking to a smaller game. The '
      'sweep dials all ${house.count == 4 ? withComma(4096) : '512'} '
      'diallings and every four-window road ends by the seventh '
      'turn. ${withComma(house.ways)} '
      'dialling${house.ways == 1 ? '' : 's'} '
      'land${house.ways == 1 ? 's' : ''} this asking.$note';
}
