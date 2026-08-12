import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shake/play.dart';
import 'palette.dart';

/// Where every guest stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.5);
    ring = math.min(room.width, room.height) * 0.38;
  }

  final Play play;

  late final Offset middle;
  late final double ring;

  /// The point of a guest, counted clockwise from the top.
  Offset guestAt(int guest) {
    final turn =
        -math.pi / 2 + 2 * math.pi * guest / play.fete.guests;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The guest under a touch, or -1.
  int guestUnder(Offset touch) {
    for (var at = 0; at < play.fete.guests; at++) {
      if ((guestAt(at) - touch).distance <= ring * 0.24) return at;
    }
    return -1;
  }
}

/// The lawn, drawn.
class LawnView extends CustomPainter {
  LawnView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The shake the show-me points at, or null.
  final ((int, int), bool)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The lawn itself.
    canvas.drawCircle(
      metrics.middle,
      metrics.ring * 1.28,
      Paint()..color = Palette.lawn,
    );

    // The handshakes.
    for (final (a, b) in play.shakes) {
      canvas.drawLine(
        metrics.guestAt(a),
        metrics.guestAt(b),
        Paint()
          ..color = Palette.shake
          ..strokeWidth = math.max(metrics.ring * 0.035, 3.0)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointed shake, dashed blue.
    final aim = pointing;
    if (aim != null) {
      final ((a, b), _) = aim;
      final from = metrics.guestAt(a);
      final to = metrics.guestAt(b);
      final way = (to - from) / (to - from).distance;
      var far = 0.0;
      final whole = (to - from).distance;
      while (far < whole) {
        final step = math.min(metrics.ring * 0.07, whole - far);
        canvas.drawLine(
          from + way * far,
          from + way * (far + step),
          Paint()
            ..color = Palette.shown
            ..strokeWidth = 2.8
            ..strokeCap = StrokeCap.round,
        );
        far += metrics.ring * 0.13;
      }
    }

    // The guests, odd-handed ones lit gold with a hand up.
    final odd = play.oddHanded.toSet();
    for (var at = 0; at < play.fete.guests; at++) {
      final middle = metrics.guestAt(at);
      final head = metrics.ring * 0.085;
      final lit = odd.contains(at);
      final picked = play.picked == at;
      if (lit) {
        canvas.drawCircle(
          middle,
          head * 2.1,
          Paint()..color = Palette.odd.withValues(alpha: 0.2),
        );
      }
      // Shoulders and head.
      canvas.drawArc(
        Rect.fromCircle(
            center: middle + Offset(0, head * 1.5),
            radius: head * 1.35),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = lit ? Palette.odd : Palette.coat
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(middle, head,
          Paint()..color = lit ? Palette.odd : Palette.coat);
      canvas.drawCircle(
        middle,
        head,
        Paint()
          ..color = picked ? Palette.shown : Palette.coatRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = picked ? 3.0 : 1.4,
      );
      if (lit) {
        // A hand up.
        canvas.drawLine(
          middle + Offset(head * 1.5, head * 0.8),
          middle + Offset(head * 2.2, -head * 0.9),
          Paint()
            ..color = Palette.odd
            ..strokeWidth = math.max(head * 0.4, 2.5)
            ..strokeCap = StrokeCap.round,
        );
      }
      if (showWords) {
        final shaken = play.hands[at];
        final words = TextPainter(
          text: TextSpan(
            text: '$shaken',
            style: labels.copyWith(
              color: lit ? Palette.odd : Palette.inkDim,
              fontSize: metrics.ring * 0.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(
          canvas,
          middle + Offset(-words.width / 2, head * 2.6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(LawnView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the lawn at hand.
String whyWords(Play play) {
  final fete = play.fete;
  final everyLawn =
      1 << (fete.guests * (fete.guests - 1) ~/ 2);
  final note = fete.note == null ? '' : ' ${fete.note}';
  if (!fete.winnable) {
    return 'The handshake lemma bars this lawn: every shake hands '
        'out exactly two, so the hand total is twice the shakes, '
        'even, and the odd-handed must pair off. Exactly one '
        'odd-handed guest would leave an odd hand total, which no '
        'count of shakes can make. The sweep laid all '
        '${withComma(everyLawn)} lawns and found none.$note';
  }
  return 'The census counts each guest\'s hands, the doubling '
      'holds the hand total to twice the shakes on every lawn, '
      'and the sweep lays all ${withComma(everyLawn)} lawns of '
      '${fete.guests} and counts ${withComma(fete.ways)} landing '
      'this asking.$note';
}
