import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../third/play.dart';
import '../third/rules.dart';
import 'palette.dart';

/// Where every stone lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height / 2);
    ring = math.min(room.width, room.height) * 0.34;
    stone = ring * 0.28;
  }

  final Play play;

  late final Offset middle;
  late final double ring;
  late final double stone;

  /// The middle of a stone, the first at the top.
  Offset stoneAt(int at) {
    final turn = -math.pi / 2 + 2 * math.pi * at / Rules.stones;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The stone under a touch, or -1 for the turf.
  int stoneUnder(Offset touch) {
    for (var at = 0; at < Rules.stones; at++) {
      if ((stoneAt(at) - touch).distance <= stone * 1.15) {
        return at;
      }
    }
    return -1;
  }
}

/// The hand, drawn: the thirds washed green beneath, then the
/// five stones and the faces they show.
class ThirdView extends CustomPainter {
  ThirdView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The stone the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final stone = metrics.stone;

    // Every third, washed as a triangle between its stones.
    for (final (a, b, c) in play.thirds) {
      final corners = [
        metrics.stoneAt(a),
        metrics.stoneAt(b),
        metrics.stoneAt(c),
      ];
      final wash = Path()..addPolygon(corners, true);
      canvas.drawPath(wash, Paint()..color = Palette.third);
      canvas.drawPath(
        wash,
        Paint()
          ..color = Palette.thirdRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    // The stones, each wearing its face in its remainder's ink.
    for (var at = 0; at < Rules.stones; at++) {
      final here = metrics.stoneAt(at);
      final face = play.faces[at];
      final heldFast =
          play.hand.locked != null && play.hand.locked!.$1 == at;

      final pebble = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: here, width: stone * 2, height: stone * 2),
        Radius.circular(stone * 0.55),
      );
      canvas.drawRRect(pebble, Paint()..color = Palette.stone);
      canvas.drawRRect(
        pebble,
        Paint()
          ..color = heldFast ? Palette.held : Palette.stoneDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = heldFast ? 3.2 : 1.8,
      );

      final wear = TextPainter(
        text: TextSpan(
          text: '$face',
          style: labels.copyWith(
            color: switch (face % 3) {
              0 => Palette.nought,
              1 => Palette.one,
              _ => Palette.two,
            },
            fontSize: stone * 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      wear.paint(
          canvas, here - Offset(wear.width / 2, wear.height / 2));

      if (heldFast) {
        final held = TextPainter(
          text: TextSpan(
            text: 'held',
            style: labels.copyWith(
              color: Palette.held,
              fontSize: stone * 0.42,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        held.paint(
            canvas, here + Offset(-held.width / 2, stone * 1.12));
      }

      if (pointing == at) {
        canvas.drawCircle(
          here,
          stone * 1.45,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ThirdView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the hand at hand.
String whyWords(Play play) {
  final hand = play.hand;
  final note = hand.note == null ? '' : ' ${hand.note}';
  if (!hand.winnable) {
    return 'Sort the five stones by their remainder of three. '
        'If some remainder shows three times, those three sum to '
        'a three-times outright; if none does, the five spread '
        'two-two-one and all three remainders show, and nought '
        'plus one plus two is three. Either way a third stands: '
        'Erdos, Ginzburg and Ziv, on one hand. The sweep dialled '
        'all ${withComma(7776)} hands and found the count landing '
        'on one, four or ten, never nought.$note';
  }
  final swept = hand.locked == null
      ? withComma(7776)
      : withComma(1296);
  return 'The thirds are counted two ways that share nothing: '
      'the census sums every triple face by face, and the '
      'two-case reading sorts the stones by remainder, a '
      'remainder shown thrice or all three shown at once. The '
      'sweep dials all $swept hands and holds the count to one, '
      'four or ten on every one. ${withComma(hand.ways)} '
      'hand${hand.ways == 1 ? '' : 's'} land${hand.ways == 1 ? 's' : ''} '
      'this asking.$note';
}
