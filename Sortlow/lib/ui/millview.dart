import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mill/play.dart';
import '../mill/rules.dart';
import 'palette.dart';

/// Where the dials stand, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    slot = math.min(room.width * 0.19, room.height * 0.16);
    left = (room.width - slot * 4 - slot * 0.36) / 2;
    top = room.height * 0.06;
  }

  final Play play;

  late final double slot;
  late final double left;
  late final double top;

  /// A dial's card.
  Rect dialOf(int at) => Rect.fromLTWH(
        left + at * (slot * 1.12),
        top,
        slot,
        slot * 1.25,
      );

  /// The dial under a touch, or -1 for the floor.
  int dialUnder(Offset touch) {
    for (var at = 0; at < 4; at++) {
      if (dialOf(at).inflate(slot * 0.08).contains(touch)) {
        return at;
      }
    }
    return -1;
  }
}

/// The mill, drawn: four dials and the whole road ground out
/// beneath them, the stone arriving in gold.
class MillView extends CustomPainter {
  MillView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The dial the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final slot = metrics.slot;

    // The dials.
    for (var at = 0; at < 4; at++) {
      final card = metrics.dialOf(at);
      final round =
          RRect.fromRectAndRadius(card, Radius.circular(slot * 0.16));
      canvas.drawRRect(round, Paint()..color = Palette.dial);
      canvas.drawRRect(
        round,
        Paint()
          ..color = Palette.dialRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
      _text(
        canvas,
        '${play.digits[at]}',
        card.center,
        labels.copyWith(
          color: Palette.chalk,
          fontSize: slot * 0.72,
          fontWeight: FontWeight.w800,
        ),
      );
      if (pointing == at) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(card.inflate(slot * 0.1),
              Radius.circular(slot * 0.2)),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The road, ground line by line.
    final roadTop = metrics.top + slot * 1.75;
    final lineHigh = math.min(
        slot * 0.62, (size.height - roadTop) / 9);
    if (play.barred) {
      _text(
        canvas,
        'all alike: barred at the door',
        Offset(size.width / 2, roadTop + lineHigh / 2),
        labels.copyWith(
            color: Palette.barred, fontSize: lineHigh * 0.42),
      );
      return;
    }
    final road = play.road;
    for (var step = 0; step + 1 < road.length && step < 8; step++) {
      final from = road[step];
      final digits = [
        from ~/ 1000,
        from ~/ 100 % 10,
        from ~/ 10 % 10,
        from % 10,
      ]..sort();
      final rising = digits[0] * 1000 +
          digits[1] * 100 +
          digits[2] * 10 +
          digits[3];
      final falling = digits[3] * 1000 +
          digits[2] * 100 +
          digits[1] * 10 +
          digits[0];
      final to = road[step + 1];
      _text(
        canvas,
        '${_worn(falling)} − ${_worn(rising)} = ${_worn(to)}',
        Offset(size.width / 2, roadTop + lineHigh * (step + 0.5)),
        labels.copyWith(
          color: to == Rules.stone ? Palette.stone : Palette.ink,
          fontSize: lineHigh * 0.52,
          fontWeight:
              to == Rules.stone ? FontWeight.w800 : FontWeight.w500,
        ),
      );
    }
    if (road.length == 1) {
      _text(
        canvas,
        'the stone itself: the mill cannot move it',
        Offset(size.width / 2, roadTop + lineHigh / 2),
        labels.copyWith(
            color: Palette.stone,
            fontSize: lineHigh * 0.44,
            fontWeight: FontWeight.w700),
      );
    }
  }

  String _worn(int number) => number.toString().padLeft(4, '0');

  void _text(
      Canvas canvas, String words, Offset at, TextStyle style) {
    final drawn = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    drawn.paint(canvas, at - Offset(drawn.width / 2, drawn.height / 2));
  }

  @override
  bool shouldRepaint(MillView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the load at hand.
String whyWords(Play play) {
  final load = play.load;
  final note = load.note == null ? '' : ' ${load.note}';
  if (!load.winnable) {
    return 'The sweep ground every allowed number, all '
        '${withComma(9990)} of them, and every road ends by the '
        'seventh turn: an eighth step exists for nobody. The '
        'table built backwards from the stone reaches everything '
        'in seven layers, and the forward walk agrees on every '
        'load.$note';
  }
  return 'A road is measured two ways that share nothing: the '
      'mill walked forward, biggest arrangement less smallest, '
      'turn upon turn; and the table built backwards from 6174 '
      'itself, layer by layer. The sweep grinds all '
      '${withComma(9990)} loads and the two never differ. '
      '${withComma(load.ways)} load${load.ways == 1 ? '' : 's'} '
      'land${load.ways == 1 ? 's' : ''} this asking.$note';
}
