import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../set/play.dart';
import 'palette.dart';

/// Where the dancers stand on the floor, so the screen and the
/// tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height / 2);
    ring = math.min(room.width, room.height) * 0.38;
    final crowd = play.dance.caller - 1;
    dancer = math.min(ring * 0.22, ring * math.pi / crowd * 0.42);
  }

  final Play play;

  late final Offset middle;
  late final double ring;

  /// A dancer's radius.
  late final double dancer;

  /// Where a dancer stands: 1 at the top, on round.
  Offset at(int number) {
    final crowd = play.dance.caller - 1;
    final turn = -math.pi / 2 + 2 * math.pi * (number - 1) / crowd;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The dancer under a touch, or null.
  int? under(Offset touch) {
    for (var number = 1; number < play.dance.caller; number++) {
      if ((at(number) - touch).distance <= dancer * 1.35) return number;
    }
    return null;
  }
}

/// The floor itself: the ring of dancers, the threads between
/// partners, and the rings of a pick or a pointer.
class SetView extends CustomPainter {
  SetView({required this.play, this.pointing, required this.labels});

  final Play play;
  final (String, int, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final caller = play.dance.caller;

    // The floor.
    canvas.drawCircle(
      metrics.middle,
      metrics.ring + metrics.dancer * 1.9,
      Paint()..color = Palette.floor,
    );
    canvas.drawCircle(
      metrics.middle,
      metrics.ring + metrics.dancer * 1.9,
      Paint()
        ..color = Palette.floorRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, metrics.dancer * 0.08),
    );

    // The caller's number in the middle.
    _write(
      canvas,
      'over $caller',
      metrics.middle,
      labels.copyWith(
        color: Palette.inkDim,
        fontSize: math.max(10, metrics.dancer * 0.9),
        fontWeight: FontWeight.w600,
      ),
    );

    // The threads between partners.
    for (final (a, b) in play.couples) {
      final sound = play.rules.comesToOne(a, b);
      canvas.drawLine(
        metrics.at(a),
        metrics.at(b),
        Paint()
          ..color = sound ? Palette.sound : Palette.sour
          ..strokeWidth = math.max(2, metrics.dancer * 0.22)
          ..strokeCap = StrokeCap.round,
      );
      // The product, written on the thread, nearer the lower
      // dancer so crossing threads keep their figures apart.
      final mid = metrics.at(a) * 0.62 + metrics.at(b) * 0.38;
      final product = (a * b) % caller;
      _write(
        canvas,
        '$product',
        mid,
        labels.copyWith(
          color: sound ? Palette.sound : Palette.sour,
          fontSize: math.max(9, metrics.dancer * 0.7),
          fontWeight: FontWeight.w700,
          backgroundColor: Palette.floor,
        ),
      );
    }

    // The dancers.
    for (var number = 1; number < caller; number++) {
      final at = metrics.at(number);
      final alone = number == 1 || number == caller - 1;
      canvas.drawCircle(
        at,
        metrics.dancer,
        Paint()..color = alone ? Palette.alone : Palette.dancer,
      );
      if (alone) {
        // A small loop: they come to one with themselves.
        canvas.drawCircle(
          at,
          metrics.dancer * 1.28,
          Paint()
            ..color = Palette.alone
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1, metrics.dancer * 0.1),
        );
      }
      if (play.picked == number) {
        canvas.drawCircle(
          at,
          metrics.dancer * 1.3,
          Paint()
            ..color = Palette.picked
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, metrics.dancer * 0.14),
        );
      }
      _write(
        canvas,
        '$number',
        at,
        labels.copyWith(
          color: Palette.dancerInk,
          fontSize: metrics.dancer * 1.0,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final ring = Paint()
        ..color = aim.$1 == 'lift' ? Palette.sour : Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, metrics.dancer * 0.14);
      canvas.drawCircle(metrics.at(aim.$2), metrics.dancer * 1.45, ring);
      canvas.drawCircle(metrics.at(aim.$3), metrics.dancer * 1.45, ring);
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
  bool shouldRepaint(SetView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a set as it stands.
String whyWords(Play play) {
  final dance = play.dance;
  final note = dance.note == null ? '' : ' ${dance.note}';
  if (!dance.winnable) {
    return 'Nine is three threes, so dancer 3 multiplied by anybody '
        'is a multiple of three, and a multiple of three is never one '
        'more than a multiple of nine: 3 has no partner, and 6 has '
        'none for the same reason. The sweep paired the six dancers '
        'off all fifteen ways and no way came to one throughout.$note';
  }
  return 'The pairings are counted by the sweep, every way of pairing '
      'the dancers off two by two, and held to a second voice: '
      'Bezout\'s arithmetic finds each dancer\'s partner by the walk of '
      'Euclid on the dancer and the caller\'s number, with no searching, '
      'and lands the sweep\'s one pairing, pair for pair. With every '
      'pair come to one, the whole set multiplied comes to one less '
      'than the caller: that is Wilson\'s theorem, and the product is '
      'taken whole in the checker for every caller to thirty.$note';
}
