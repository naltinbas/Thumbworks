import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../deal/play.dart';
import '../deal/rules.dart';
import 'palette.dart';

/// Where every pile stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    slots = play.piles.length + (play.pool > 0 ? 1 : 0);
    final across = math.max(slots, 4);
    slot = math.min(room.width * 0.9 / across, room.height * 0.1);
    left = (room.width - slot * slots) / 2;
    floor = room.height * 0.42;
  }

  final Play play;

  late final int slots;
  late final double slot;
  late final double left;
  late final double floor;

  /// A slot's footing.
  Offset slotAt(int at) =>
      Offset(left + (at + 0.5) * slot, floor);

  /// The slot under a touch, or -1 for the turf: anywhere in
  /// the slot's column above the floor.
  int slotUnder(Offset touch) {
    if (touch.dy > floor + slot * 0.6) return -1;
    for (var at = 0; at < slots; at++) {
      if ((touch.dx - slotAt(at).dx).abs() <= slot * 0.5) {
        return at;
      }
    }
    return -1;
  }
}

/// The hand, drawn: piles of stones on their slots, the pool
/// beneath, and the whole road dealt out below.
class DealView extends CustomPainter {
  DealView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The slot the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final slot = metrics.slot;

    // The slots and their piles.
    for (var at = 0; at < metrics.slots; at++) {
      final footing = metrics.slotAt(at);
      canvas.drawLine(
        footing + Offset(-slot * 0.42, slot * 0.5),
        footing + Offset(slot * 0.42, slot * 0.5),
        Paint()
          ..color = Palette.slotRim
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
      final pile = at < play.piles.length ? play.piles[at] : 0;
      for (var stone = 0; stone < pile; stone++) {
        canvas.drawCircle(
          footing + Offset(0, slot * 0.14 - stone * slot * 0.62),
          slot * 0.3,
          Paint()..color = Palette.stone,
        );
        canvas.drawCircle(
          footing + Offset(0, slot * 0.14 - stone * slot * 0.62),
          slot * 0.3,
          Paint()
            ..color = Palette.stoneRim
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
      if (pointing == at) {
        canvas.drawCircle(
          footing + Offset(0, slot * 0.14),
          slot * 0.48,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The pool.
    final poolAt = Offset(size.width / 2, metrics.floor + slot * 1.3);
    if (play.pool > 0) {
      for (var stone = 0; stone < play.pool; stone++) {
        canvas.drawCircle(
          poolAt + Offset((stone - (play.pool - 1) / 2) * slot * 0.5, 0),
          slot * 0.22,
          Paint()..color = Palette.pool,
        );
      }
      _text(
        canvas,
        'the pool',
        poolAt + Offset(0, slot * 0.62),
        labels.copyWith(
            color: Palette.inkDim, fontSize: slot * 0.3),
      );
    }

    // The road, dealt line by line once the pool is spent; a
    // hand whose count holds no stair walks its endless start.
    final roadTop = metrics.floor + slot * 2.2;
    var road = play.road;
    var endless = false;
    if (play.pool == 0 && road.length == 1 && play.deals < 0) {
      endless = true;
      var at = List.of(play.piles);
      road = [at];
      for (var step = 0; step < 5; step++) {
        at = Rules.deal(at);
        road = [...road, at];
      }
    }
    if (play.pool == 0 && road.length > 1) {
      final lineHigh = math.min(
          slot * 0.72, (size.height - roadTop) / road.length);
      for (var step = 0; step < road.length && step < 14; step++) {
        final hand = road[step];
        final last = !endless && step == road.length - 1;
        _text(
          canvas,
          endless && step == road.length - 1
              ? '${hand.join(' · ')} and on for ever'
              : hand.join(' · '),
          Offset(size.width / 2, roadTop + lineHigh * (step + 0.5)),
          labels.copyWith(
            color: last ? Palette.stair : Palette.ink,
            fontSize: lineHigh * 0.52,
            fontWeight: last ? FontWeight.w800 : FontWeight.w500,
          ),
        );
      }
    }
    if (play.pool == 0 && road.length == 1 && play.deals == 0) {
      _text(
        canvas,
        'the stair itself: the deal pays it straight back',
        Offset(size.width / 2, roadTop + slot * 0.4),
        labels.copyWith(
            color: Palette.stair,
            fontSize: slot * 0.36,
            fontWeight: FontWeight.w700),
      );
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
  bool shouldRepaint(DealView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the handful at hand.
String whyWords(Play play) {
  final handful = play.handful;
  final note = handful.note == null ? '' : ' ${handful.note}';
  if (!handful.winnable) {
    return 'A hand that stands still must take back exactly what '
        'it pays: the takings pile holds one stone per pile, so it '
        'must equal the biggest, and pile by pile the whole hand '
        'is forced into the stair, each step one below the next. '
        'Stairs hold one, three, six or ten stones, and eight is '
        'none of them. The sweep dealt all 22 hands of eight and '
        'not one stood still.$note';
  }
  return 'The road is measured by the deal itself, walked hand '
      'over hand to the stair, and held against the sweep: every '
      'hand of ${handful.stones} dealt to its count, '
      '${handful.stones == 6 ? '11' : '42'} of them, each '
      'reaching the stair inside sixty deals with the counts '
      'landing where the labels say. ${handful.ways} '
      'hand${handful.ways == 1 ? '' : 's'} '
      'land${handful.ways == 1 ? 's' : ''} this asking.$note';
}
