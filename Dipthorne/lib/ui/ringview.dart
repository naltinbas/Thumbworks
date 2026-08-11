import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ring/play.dart';
import 'palette.dart';

/// Where everyone stands, shared by the painter and the hit-testing, so
/// where a seat is drawn is exactly where a seat is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    middle = Offset(width / 2, height / 2);
    around = math.min(width, height) / 2 * 0.78;
    seat = math.min(
      around * math.sin(math.pi / play.ring.children) * 0.82,
      around * 0.16,
    );
  }

  final Play play;

  late final double width;
  late final double height;
  late final Offset middle;

  /// The ring's radius, and a seat's.
  late final double around;
  late final double seat;

  /// Where a seat stands, 1-counted, seat 1 at the top and the ring
  /// running the way of the sun.
  Offset seatAt(int number) {
    final turn = (number - 1) / play.ring.children * 2 * math.pi - math.pi / 2;
    return middle + Offset(math.cos(turn), math.sin(turn)) * around;
  }

  /// The seat under a touch, or -1 for nowhere.
  int seatUnder(Offset touch) {
    for (var number = 1; number <= play.ring.children; number++) {
      if ((seatAt(number) - touch).distance <= seat * 1.5) return number;
    }
    return -1;
  }
}

/// The yard, drawn.
class RingView extends CustomPainter {
  RingView({
    required this.play,
    required this.pointing,
    required this.showSafe,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The seat being pointed at, or -1.
  final int pointing;

  /// Whether to mark the safe seat in gold.
  final bool showSafe;

  /// Whether to number the seats. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    _stone(canvas, metrics);
    for (var seat = 1; seat <= play.ring.children; seat++) {
      _child(canvas, metrics, seat);
    }
    if (play.hasChosen && !play.isOver) _finger(canvas, metrics);
    if (showSafe) _safe(canvas, metrics);
    if (pointing >= 1) _point(canvas, metrics);
  }

  void _stone(Canvas canvas, Metrics metrics) {
    // The dip stone, just outside seat 1, where the count begins.
    final above = metrics.seatAt(1) -
        Offset(0, metrics.seat * 2.1);
    final stone = Rect.fromCenter(
      center: above,
      width: metrics.seat * 1.5,
      height: metrics.seat * 1.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(stone, Radius.circular(stone.height * 0.45)),
      Paint()..color = Palette.stone,
    );
  }

  void _child(Canvas canvas, Metrics metrics, int seat) {
    final where = metrics.seatAt(seat);
    final isIn = play.isIn(seat);
    final isYou = seat == play.chosen;

    final body = Paint()
      ..color = isYou
          ? Palette.you
          : isIn
              ? Palette.child
              : Palette.gone;

    // A child: a round head over a small cape of shoulders.
    canvas.drawCircle(
      where + Offset(0, metrics.seat * 0.28),
      metrics.seat * 0.72,
      body,
    );
    canvas.drawCircle(
      where - Offset(0, metrics.seat * 0.42),
      metrics.seat * 0.46,
      body,
    );

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: isYou ? 'you' : '$seat',
        style: labels.copyWith(
          color: isIn || isYou ? Palette.dusk : Palette.inkDim,
          fontSize: metrics.seat * (isYou ? 0.62 : 0.72),
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      where + Offset(-words.width / 2, metrics.seat * 0.28 - words.height / 2),
    );
  }

  void _finger(Canvas canvas, Metrics metrics) {
    // The dipper's finger: a wedge just outside the child the chant stands
    // on, pointing in at them.
    final at = play.standing[play.from];
    final where = metrics.seatAt(at);
    final outward = (where - metrics.middle);
    final way = outward / outward.distance;
    final tip = where + way * metrics.seat * 1.7;
    final side = Offset(-way.dy, way.dx);

    final finger = Path()
      ..moveTo(tip.dx + way.dx * metrics.seat * 0.9,
          tip.dy + way.dy * metrics.seat * 0.9)
      ..lineTo(tip.dx + side.dx * metrics.seat * 0.5,
          tip.dy + side.dy * metrics.seat * 0.5)
      ..lineTo(tip.dx - side.dx * metrics.seat * 0.5,
          tip.dy - side.dy * metrics.seat * 0.5)
      ..close();
    canvas.drawPath(finger, Paint()..color = Palette.finger);
  }

  void _safe(Canvas canvas, Metrics metrics) {
    canvas.drawCircle(
      metrics.seatAt(play.safe),
      metrics.seat * 1.5,
      Paint()
        ..color = Palette.safeSeat
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  void _point(Canvas canvas, Metrics metrics) {
    canvas.drawCircle(
      metrics.seatAt(pointing),
      metrics.seat * 1.8,
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(RingView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showSafe != showSafe;
}

/// The words the why speaks, built from the ring at hand.
String whyWords(Play play) {
  final ring = play.ring;
  if (ring.beats == 2) {
    final size = ring.children.toRadixString(2);
    final turned = size.substring(1) + size.substring(0, 1);
    return 'Two beats is the old trick: write the ring\'s size in binary '
        'and move the front figure to the back. $size turns to $turned, '
        'which is ${ring.safe}: the safe seat, counted from the dip stone. '
        'The reckoning and the count run out loud both agree.'
        '${ring.note == null ? '' : ' ${ring.note}'}';
  }
  return 'A ring of ${ring.children} is a ring of ${ring.children - 1} '
      'wearing new numbers: whoever is safe there sits ${ring.beats} seats '
      'further round here. Climb that from a ring of one and the reckoning '
      'lands on seat ${ring.safe}. The count, run out loud, agrees on '
      'every ring the suite sweeps.'
      '${ring.note == null ? '' : ' ${ring.note}'}';
}
